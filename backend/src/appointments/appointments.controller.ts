import { Controller, Post, Get, Body, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { AppointmentsService } from './appointments.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { RolesGuard } from '../common/guards/roles.guard';
import { Roles } from '../common/decorators/roles.decorator';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { Role } from '@prisma/client';

@ApiTags('Doctor Appointments')
@Controller('api/v1/appointments')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class AppointmentsController {
  constructor(private appointmentsService: AppointmentsService) {}

  @Post()
  @ApiOperation({ summary: 'Book doctor consultation appointment' })
  createAppointment(
    @CurrentUser('id') userId: string,
    @Body() body: { doctorId: string; date: string; timeSlot: string; symptoms?: string },
  ) {
    return this.appointmentsService.createAppointment(userId, body);
  }

  @Get('my-appointments')
  @ApiOperation({ summary: 'Get current patient appointments' })
  getMyAppointments(@CurrentUser('id') userId: string) {
    return this.appointmentsService.getMyAppointments(userId);
  }

  @Get()
  @UseGuards(RolesGuard)
  @Roles(Role.ADMIN, Role.RECEPTIONIST, Role.DOCTOR)
  @ApiOperation({ summary: 'Get all appointments (Receptionist / Admin / Doctor)' })
  getAllAppointments() {
    return this.appointmentsService.getAllAppointments();
  }
}
