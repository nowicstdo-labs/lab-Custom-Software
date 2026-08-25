import { Injectable, UnauthorizedException, BadRequestException, ConflictException, NotFoundException, Logger } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { PrismaService } from '../database/prisma.service';
import { EmailService } from '../common/email/email.service';
import { RegisterPatientDto, LoginDto, RefreshTokenDto, GoogleLoginDto, ForgotPasswordDto, ResetPasswordDto } from './dto/auth.dto';
import { Role } from '@prisma/client';
import * as argon2 from 'argon2';

@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name);

  constructor(
    private prisma: PrismaService,
    private jwtService: JwtService,
    private emailService: EmailService,
  ) {}

  async registerPatient(dto: RegisterPatientDto) {
    const normalizedEmail = dto.email.trim().toLowerCase();

    const existingEmail = await this.prisma.user.findUnique({ where: { email: normalizedEmail } });
    if (existingEmail) {
      throw new ConflictException('An account with this email address already exists.');
    }

    if (dto.phone && dto.phone.trim().length > 0) {
      const normalizedPhone = dto.phone.trim();
      const existingPhone = await this.prisma.user.findFirst({ where: { phone: normalizedPhone } });
      if (existingPhone) {
        throw new ConflictException('An account with this mobile number already exists.');
      }
    }

    const passwordHash = await argon2.hash(dto.password);

    let patientId = `ASTH-P-${Math.floor(100000 + Math.random() * 900000)}`;
    let attempts = 0;
    while (attempts < 5) {
      const existingProfile = await this.prisma.patientProfile.findUnique({ where: { patientId } });
      if (!existingProfile) break;
      patientId = `ASTH-P-${Math.floor(100000 + Math.random() * 900000)}`;
      attempts++;
    }

    try {
      const user = await this.prisma.user.create({
        data: {
          name: dto.name.trim(),
          email: normalizedEmail,
          passwordHash,
          role: Role.PATIENT,
          phone: dto.phone ? dto.phone.trim() : null,
          patientProfile: {
            create: {
              patientId,
            },
          },
        },
        include: { patientProfile: true },
      });

      this.logger.log(`Successfully registered new patient: ${user.email} (ID: ${patientId})`);
      return this.generateTokens(user.id, user.email, user.role, user.name);
    } catch (error) {
      this.logger.error(`Error during patient registration for ${normalizedEmail}: ${error instanceof Error ? error.message : String(error)}`);
      throw error;
    }
  }

  async login(dto: LoginDto) {
    const normalizedEmail = dto.email.trim().toLowerCase();
    const user = await this.prisma.user.findUnique({ where: { email: normalizedEmail } });
    if (!user) {
      throw new UnauthorizedException('Invalid email or password credentials');
    }

    if (!user.isActive) {
      throw new UnauthorizedException('Account is disabled. Please contact administration.');
    }

    const isMatch = await argon2.verify(user.passwordHash, dto.password);
    if (!isMatch) {
      throw new UnauthorizedException('Invalid email or password credentials');
    }

    return this.generateTokens(user.id, user.email, user.role, user.name);
  }

  async googleLogin(dto: GoogleLoginDto) {
    let googlePayload: { email?: string; name?: string; picture?: string };
    try {
      const response = await fetch(`https://oauth2.googleapis.com/tokeninfo?id_token=${encodeURIComponent(dto.idToken)}`);
      if (!response.ok) {
        throw new UnauthorizedException('Invalid Google ID token provided');
      }
      googlePayload = (await response.json()) as any;
    } catch (e) {
      throw new UnauthorizedException('Google authentication failed: unable to verify token');
    }

    const email = googlePayload.email?.trim().toLowerCase();
    if (!email) {
      throw new UnauthorizedException('Google token did not contain a valid email address');
    }

    let user = await this.prisma.user.findUnique({ where: { email } });
    if (!user) {
      const randomPassword = Math.random().toString(36).slice(-10) + 'A1!';
      const passwordHash = await argon2.hash(randomPassword);
      let patientId = `ASTH-P-${Math.floor(100000 + Math.random() * 900000)}`;
      user = await this.prisma.user.create({
        data: {
          name: googlePayload.name || email.split('@')[0],
          email: email,
          passwordHash,
          role: Role.PATIENT,
          patientProfile: {
            create: {
              patientId,
            },
          },
        },
      });
    }

    if (!user.isActive) {
      throw new UnauthorizedException('Account is inactive. Please contact support.');
    }

    return this.generateTokens(user.id, user.email, user.role, user.name);
  }

  async forgotPassword(dto: ForgotPasswordDto) {
    const key = dto.emailOrPhone.trim().toLowerCase();

    const user = await this.prisma.user.findFirst({
      where: {
        OR: [
          { email: key },
          { phone: key },
        ],
      },
    });

    if (!user) {
      throw new NotFoundException('No account found with this email address or mobile number.');
    }

    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    const otpHash = await argon2.hash(otp);
    const expiresAt = new Date(Date.now() + 10 * 60 * 1000); // 10 minutes

    await this.prisma.oTPVerification.create({
      data: {
        phoneOrEmail: user.email.toLowerCase(),
        otpHash,
        expiresAt,
      },
    });

    try {
      await this.emailService.sendPasswordResetEmail(user.email, otp);
    } catch (e) {
      this.logger.error(`Error attempting to send password reset email to ${user.email}: ${e instanceof Error ? e.message : String(e)}`);
    }

    return {
      success: true,
      message: 'Password reset code has been sent.',
      otp: this.emailService.isConfigured() ? undefined : otp,
    };
  }

  async resetPassword(dto: ResetPasswordDto) {
    const key = dto.emailOrPhone.trim().toLowerCase();

    const user = await this.prisma.user.findFirst({
      where: {
        OR: [
          { email: key },
          { phone: key },
        ],
      },
    });

    if (!user) {
      throw new NotFoundException('User account not found.');
    }

    const otps = await this.prisma.oTPVerification.findMany({
      where: {
        phoneOrEmail: { in: [key, user.email.toLowerCase(), user.phone || ''].filter(Boolean) },
        isVerified: false,
        expiresAt: { gte: new Date() },
      },
      orderBy: { createdAt: 'desc' },
    });

    if (!otps || otps.length === 0) {
      throw new BadRequestException('Invalid or expired verification code');
    }

    let validOtpId: string | null = null;
    for (const record of otps) {
      const match = await argon2.verify(record.otpHash, dto.otp);
      if (match) {
        validOtpId = record.id;
        break;
      }
    }

    if (!validOtpId) {
      throw new BadRequestException('Invalid verification code entered');
    }

    await this.prisma.oTPVerification.update({
      where: { id: validOtpId },
      data: { isVerified: true },
    });

    const newHash = await argon2.hash(dto.newPassword);
    await this.prisma.user.update({
      where: { id: user.id },
      data: { passwordHash: newHash },
    });

    await this.prisma.refreshToken.deleteMany({ where: { userId: user.id } });

    this.logger.log(`Password reset successfully for user: ${user.email}`);
    return { success: true, message: 'Password has been reset successfully. Please log in with your new password.' };
  }

  async refreshTokens(dto: RefreshTokenDto) {
    try {
      const secret = process.env.JWT_REFRESH_SECRET || process.env.JWT_SECRET || 'astha_refresh_secret_key';
      const payload = this.jwtService.verify(dto.refreshToken, { secret });

      const user = await this.prisma.user.findUnique({ where: { id: payload.sub } });
      if (!user || !user.isActive) {
        throw new UnauthorizedException('Invalid refresh token session');
      }

      return this.generateTokens(user.id, user.email, user.role, user.name);
    } catch (_) {
      throw new UnauthorizedException('Invalid or expired refresh token');
    }
  }

  async logout(userId: string) {
    await this.prisma.refreshToken.deleteMany({ where: { userId } });
    return { message: 'Logged out successfully' };
  }

  private async generateTokens(userId: string, email: string, role: Role, name?: string) {
    const payload = { sub: userId, email, role, name };
    const accessSecret = process.env.JWT_ACCESS_SECRET || process.env.JWT_SECRET || 'astha_access_secret_key';
    const refreshSecret = process.env.JWT_REFRESH_SECRET || process.env.JWT_SECRET || 'astha_refresh_secret_key';

    const accessToken = this.jwtService.sign(payload, {
      secret: accessSecret,
      expiresIn: process.env.ACCESS_TOKEN_EXPIRES_IN || '15m',
    });
    const refreshToken = this.jwtService.sign(payload, {
      secret: refreshSecret,
      expiresIn: process.env.REFRESH_TOKEN_EXPIRES_IN || '7d',
    });

    return {
      user: { id: userId, email, role, name },
      accessToken,
      refreshToken,
    };
  }
}
