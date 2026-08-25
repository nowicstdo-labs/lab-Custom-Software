import { Logger } from '@nestjs/common';

export function validateEnvironment(): void {
  const logger = new Logger('EnvValidation');

  const databaseUrl = process.env.DATABASE_URL;
  if (!databaseUrl || databaseUrl.trim() === '') {
    logger.error('CRITICAL: DATABASE_URL environment variable is missing!');
  } else {
    logger.log('✓ DATABASE_URL configured');
  }

  const jwtSecret = process.env.JWT_ACCESS_SECRET || process.env.JWT_SECRET;
  if (!jwtSecret || jwtSecret.trim() === '') {
    logger.error('CRITICAL: JWT_ACCESS_SECRET / JWT_SECRET environment variable is missing!');
  } else {
    logger.log('✓ JWT secret configured');
  }

  const jwtRefreshSecret = process.env.JWT_REFRESH_SECRET || process.env.JWT_SECRET;
  if (!jwtRefreshSecret || jwtRefreshSecret.trim() === '') {
    logger.warn('WARNING: JWT_REFRESH_SECRET is missing! Falling back to primary JWT secret.');
  } else {
    logger.log('✓ JWT refresh secret configured');
  }

  const smtpHost = process.env.SMTP_HOST;
  const smtpUser = process.env.SMTP_USER;
  const smtpPass = process.env.SMTP_PASSWORD;
  if (!smtpHost || !smtpUser || !smtpPass) {
    logger.warn(
      'WARNING: SMTP environment variables (SMTP_HOST, SMTP_USER, SMTP_PASSWORD) are not fully configured. Password reset emails will log OTP to server console.',
    );
  } else {
    logger.log('✓ SMTP email service configured');
  }
}
