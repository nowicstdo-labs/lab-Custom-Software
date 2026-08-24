import { IsEmail, IsNotEmpty, IsString, MinLength } from 'class-validator';

export class RegisterPatientDto {
  @IsNotEmpty()
  @IsString()
  name: string;

  @IsEmail()
  email: string;

  @IsNotEmpty()
  @MinLength(6)
  password: string;

  @IsString()
  phone?: string;
}

export class LoginDto {
  @IsEmail()
  email: string;

  @IsNotEmpty()
  password: string;
}

export class RefreshTokenDto {
  @IsNotEmpty()
  refreshToken: string;
}

export class GoogleLoginDto {
  @IsNotEmpty()
  @IsString()
  idToken: string;
}

export class ForgotPasswordDto {
  @IsNotEmpty()
  @IsString()
  emailOrPhone: string;
}

export class ResetPasswordDto {
  @IsNotEmpty()
  @IsString()
  emailOrPhone: string;

  @IsNotEmpty()
  @IsString()
  otp: string;

  @IsNotEmpty()
  @MinLength(6)
  newPassword: string;
}

