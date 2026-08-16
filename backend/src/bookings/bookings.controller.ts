import { Controller, Post, Get, Body, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { BookingsService } from './bookings.service';
import { CreateBookingDto } from './dto/booking.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';

@ApiTags('Test Bookings')
@Controller('api/v1/bookings')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class BookingsController {
  constructor(private bookingsService: BookingsService) {}

  @Post()
  @ApiOperation({ summary: 'Book diagnostic test (Transactionally enforces max 10 patient slot capacity)' })
  createBooking(@CurrentUser('id') userId: string, @Body() dto: CreateBookingDto) {
    return this.bookingsService.createBooking(userId, dto);
  }

  @Get('my-bookings')
  @ApiOperation({ summary: 'Get current patient bookings' })
  getMyBookings(@CurrentUser('id') userId: string) {
    return this.bookingsService.getPatientBookings(userId);
  }

  @Get()
  @ApiOperation({ summary: 'Get all bookings (Receptionist / Admin)' })
  getAllBookings() {
    return this.bookingsService.getAllBookings();
  }
}
