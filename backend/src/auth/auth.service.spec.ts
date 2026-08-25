import { Test, TestingModule } from '@nestjs/testing';
import { AuthService } from './auth.service';
import { PrismaService } from '../database/prisma.service';
import { JwtService } from '@nestjs/jwt';
import { EmailService } from '../common/email/email.service';
import { ConflictException, NotFoundException, BadRequestException } from '@nestjs/common';

describe('AuthService', () => {
  let service: AuthService;
  let prisma: any;
  let emailService: any;

  const mockPrismaService = {
    user: {
      findUnique: jest.fn(),
      findFirst: jest.fn(),
      create: jest.fn(),
      update: jest.fn(),
    },
    patientProfile: {
      findUnique: jest.fn(),
    },
    oTPVerification: {
      create: jest.fn(),
      findMany: jest.fn(),
      update: jest.fn(),
    },
    refreshToken: {
      deleteMany: jest.fn(),
    },
  };

  const mockJwtService = {
    sign: jest.fn().mockReturnValue('mock_token'),
    verify: jest.fn(),
  };

  const mockEmailService = {
    sendPasswordResetEmail: jest.fn().mockResolvedValue(true),
    isConfigured: jest.fn().mockReturnValue(true),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AuthService,
        { provide: PrismaService, useValue: mockPrismaService },
        { provide: JwtService, useValue: mockJwtService },
        { provide: EmailService, useValue: mockEmailService },
      ],
    }).compile();

    service = module.get<AuthService>(AuthService);
    prisma = module.get<PrismaService>(PrismaService);
    emailService = module.get<EmailService>(EmailService);

    jest.clearAllMocks();
  });

  describe('registerPatient', () => {
    it('should register a new patient successfully', async () => {
      mockPrismaService.user.findUnique.mockResolvedValue(null);
      mockPrismaService.patientProfile.findUnique.mockResolvedValue(null);
      mockPrismaService.user.create.mockResolvedValue({
        id: 'user-uuid-1',
        email: 'newpatient@example.com',
        name: 'John Doe',
        role: 'PATIENT',
      });

      const result = await service.registerPatient({
        name: 'John Doe',
        email: 'newpatient@example.com',
        password: 'Password123!',
      });

      expect(result).toBeDefined();
      expect(result.accessToken).toBe('mock_token');
      expect(mockPrismaService.user.create).toHaveBeenCalled();
    });

    it('should throw ConflictException if user with email already exists', async () => {
      mockPrismaService.user.findUnique.mockResolvedValue({ id: 'existing-id', email: 'existing@example.com' });

      await expect(
        service.registerPatient({
          name: 'John Doe',
          email: 'existing@example.com',
          password: 'Password123!',
        }),
      ).rejects.toThrow(ConflictException);
    });
  });

  describe('forgotPassword', () => {
    it('should throw NotFoundException if account does not exist', async () => {
      mockPrismaService.user.findFirst.mockResolvedValue(null);

      await expect(
        service.forgotPassword({ emailOrPhone: 'nonexistent@example.com' }),
      ).rejects.toThrow(NotFoundException);
    });

    it('should generate OTP and trigger email for existing account', async () => {
      mockPrismaService.user.findFirst.mockResolvedValue({
        id: 'user-uuid-1',
        email: 'user@example.com',
      });
      mockPrismaService.oTPVerification.create.mockResolvedValue({ id: 'otp-id' });

      const res = await service.forgotPassword({ emailOrPhone: 'user@example.com' });

      expect(res.success).toBe(true);
      expect(mockPrismaService.oTPVerification.create).toHaveBeenCalled();
      expect(mockEmailService.sendPasswordResetEmail).toHaveBeenCalled();
    });
  });
});
