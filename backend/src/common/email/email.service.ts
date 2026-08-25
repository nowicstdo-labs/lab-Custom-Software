import { Injectable, Logger, InternalServerErrorException } from '@nestjs/common';
import * as nodemailer from 'nodemailer';

@Injectable()
export class EmailService {
  private readonly logger = new Logger(EmailService.name);
  private transporter: nodemailer.Transporter | null = null;

  constructor() {
    this.initTransporter();
  }

  private initTransporter() {
    const host = process.env.SMTP_HOST;
    const port = parseInt(process.env.SMTP_PORT || '587', 10);
    const user = process.env.SMTP_USER;
    const pass = process.env.SMTP_PASSWORD;

    if (host && user && pass) {
      this.transporter = nodemailer.createTransport({
        host,
        port,
        secure: port === 465,
        auth: {
          user,
          pass,
        },
      });
      this.logger.log(`SMTP Email transporter initialized for host: ${host}:${port}`);
    } else {
      this.logger.warn(
        `SMTP Email configuration incomplete. Missing required env vars: SMTP_HOST, SMTP_USER, SMTP_PASSWORD. Email delivery will be simulated.`,
      );
    }
  }

  public isConfigured(): boolean {
    const host = process.env.SMTP_HOST;
    const user = process.env.SMTP_USER;
    const pass = process.env.SMTP_PASSWORD;
    return Boolean(host && user && pass);
  }

  async sendPasswordResetEmail(toEmail: string, otp: string): Promise<boolean> {
    const fromAddress = process.env.SMTP_FROM || process.env.MAIL_FROM || process.env.EMAIL_FROM || 'no-reply@asthadiagnostic.com';

    if (!this.transporter) {
      this.initTransporter();
    }

    if (!this.transporter) {
      this.logger.warn(
        `[DIAGNOSTIC] Password reset requested for ${toEmail}. SMTP not configured on Render. Generated OTP: ${otp}. Please set SMTP_HOST, SMTP_PORT, SMTP_USER, SMTP_PASSWORD, SMTP_FROM in Render dashboard.`,
      );
      return false;
    }

    const htmlContent = `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #e0e0e0; border-radius: 10px;">
        <h2 style="color: #0077B6; text-align: center;">Astha Diagnostic</h2>
        <h3 style="color: #333;">Password Reset Request</h3>
        <p>Hello,</p>
        <p>We received a request to reset your password for your Astha Diagnostic account.</p>
        <p>Your 6-digit verification code is:</p>
        <div style="background-color: #f0f4f8; padding: 15px; text-align: center; border-radius: 8px; font-size: 28px; font-weight: bold; letter-spacing: 5px; color: #0077B6;">
          ${otp}
        </div>
        <p style="margin-top: 20px;">This code will expire in <strong>10 minutes</strong>.</p>
        <p>If you did not request a password reset, please ignore this email or contact support if you have concerns.</p>
        <hr style="border: none; border-top: 1px solid #eee; margin: 20px 0;" />
        <p style="font-size: 12px; color: #777; text-align: center;">&copy; ${new Date().getFullYear()} Astha Diagnostic. All rights reserved.</p>
      </div>
    `;

    try {
      await this.transporter.sendMail({
        from: `"Astha Diagnostic" <${fromAddress}>`,
        to: toEmail,
        subject: 'Astha Diagnostic - Password Reset Verification Code',
        html: htmlContent,
      });
      this.logger.log(`Password reset email successfully sent to ${toEmail}`);
      return true;
    } catch (error) {
      this.logger.error(`Failed to send password reset email to ${toEmail}: ${error instanceof Error ? error.message : String(error)}`);
      throw new InternalServerErrorException('Unable to send password reset email. Please try again later or contact support.');
    }
  }
}
