import { IsNotEmpty, IsNumber, IsString } from 'class-validator';

export class CreateBookingDto {
  @IsNotEmpty()
  @IsString()
  testId: string;

  @IsNotEmpty()
  @IsString()
  appointmentDate: string;

  @IsNotEmpty()
  @IsString()
  timeSlot: string;

  @IsNotEmpty()
  @IsNumber()
  price: number;
}
