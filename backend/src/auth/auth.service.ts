import { Injectable, UnauthorizedException, BadRequestException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { PrismaService } from '../database/prisma.service';
import { RegisterPatientDto, LoginDto, RefreshTokenDto, GoogleLoginDto, ForgotPasswordDto, ResetPasswordDto } from './dto/auth.dto';
import { Role } from '@prisma/client';
import * as argon2 from 'argon2';

@Injectable()
export class AuthService {
  constructor(
    private prisma: PrismaService,
    private jwtService: JwtService,
  ) {}

  async registerPatient(dto: RegisterPatientDto) {
    const existing = await this.prisma.user.findUnique({ where: { email: dto.email.toLowerCase() } });
    if (existing) {
      throw new BadRequestException('An account with this email already exists');
    }

    const passwordHash = await argon2.hash(dto.password);
    const user = await this.prisma.user.create({
      data: {
        name: dto.name,
        email: dto.email.toLowerCase(),
        passwordHash,
        role: Role.PATIENT, // Public sign-up strictly assigns PATIENT
        phone: dto.phone,
        patientProfile: {
          create: {
            patientId: `ASTH-P-${Math.floor(100000 + Math.random() * 900000)}`,
          },
        },
      },
      include: { patientProfile: true },
    });

    return this.generateTokens(user.id, user.email, user.role, user.name);
  }

  async login(dto: LoginDto) {
    const user = await this.prisma.user.findUnique({ where: { email: dto.email.toLowerCase() } });
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

    const email = googlePayload.email?.toLowerCase();
    if (!email) {
      throw new UnauthorizedException('Google token did not contain a valid email address');
    }

    let user = await this.prisma.user.findUnique({ where: { email } });
    if (!user) {
      const randomPassword = Math.random().toString(36).slice(-10) + 'A1!';
      const passwordHash = await argon2.hash(randomPassword);
      user = await this.prisma.user.create({
        data: {
          name: googlePayload.name || email.split('@')[0],
          email: email,
          passwordHash,
          role: Role.PATIENT,
          patientProfile: {
            create: {
              patientId: `ASTH-P-${Math.floor(100000 + Math.random() * 900000)}`,
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
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    const otpHash = await argon2.hash(otp);
    const expiresAt = new Date(Date.now() + 10 * 60 * 1000); // 10 minutes

    await this.prisma.oTPVerification.create({
      data: {
        phoneOrEmail: key,
        otpHash,
        expiresAt,
      },
    });

    console.log(`[AUTH] Generated OTP for ${key}: ${otp}`);
    return { success: true, message: 'OTP sent successfully', otp };
  }

  async resetPassword(dto: ResetPasswordDto) {
    const key = dto.emailOrPhone.trim().toLowerCase();
    const otps = await this.prisma.oTPVerification.findMany({
      where: {
        phoneOrEmail: key,
        isVerified: false,
        expiresAt: { gte: new Date() },
      },
      orderBy: { createdAt: 'desc' },
    });

    if (!otps || otps.length === 0) {
      throw new BadRequestException('Invalid or expired OTP code');
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
      throw new BadRequestException('Invalid OTP code entered');
    }

    await this.prisma.oTPVerification.update({
      where: { id: validOtpId },
      data: { isVerified: true },
    });

    const user = await this.prisma.user.findFirst({
      where: {
        OR: [{ email: key }, { phone: key }],
      },
    });

    if (!user) {
      throw new BadRequestException('User account not found');
    }

    const newHash = await argon2.hash(dto.newPassword);
    await this.prisma.user.update({
      where: { id: user.id },
      data: { passwordHash: newHash },
    });

    return { success: true, message: 'Password reset successfully' };
  }

  async refreshTokens(dto: RefreshTokenDto) {
    try {
      const payload = this.jwtService.verify(dto.refreshToken, {
        secret: process.env.JWT_REFRESH_SECRET || 'astha_refresh_secret_key',
      });

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
    const accessToken = this.jwtService.sign(payload, {
      secret: process.env.JWT_ACCESS_SECRET || 'astha_access_secret_key',
      expiresIn: '15m',
    });
    const refreshToken = this.jwtService.sign(payload, {
      secret: process.env.JWT_REFRESH_SECRET || 'astha_refresh_secret_key',
      expiresIn: '7d',
    });

    return {
      user: { id: userId, email, role, name },
      accessToken,
      refreshToken,
    };
  }
}

