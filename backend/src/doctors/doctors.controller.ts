import { Controller, Get, Post, Patch, Param, Body, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { DoctorsService } from './doctors.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { RolesGuard } from '../common/guards/roles.guard';
import { Roles } from '../common/decorators/roles.decorator';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { Role } from '@prisma/client';

@ApiTags('Doctor Operations')
@Controller('api/v1/doctors')
export class DoctorsController {
  constructor(private doctorsService: DoctorsService) {}

  @Get()
  @ApiOperation({ summary: 'Get list of active diagnostic doctors and specialists' })
  getAllDoctors() {
    return this.doctorsService.getAllDoctors();
  }

  @Post()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(Role.ADMIN)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Admin create doctor profile' })
  createDoctor(@Body() body: any) {
    return this.doctorsService.createDoctor(body);
  }

  @Patch(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(Role.ADMIN)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Admin update doctor profile' })
  updateDoctor(@Param('id') id: string, @Body() body: any) {
    return this.doctorsService.updateDoctor(id, body);
  }

  @Get('appointments')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(Role.DOCTOR)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get appointments assigned to the logged-in doctor' })
  getDoctorAppointments(@CurrentUser('id') userId: string) {
    return this.doctorsService.getDoctorAppointments(userId);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get doctor details by Doctor ID' })
  getDoctorById(@Param('id') id: string) {
    return this.doctorsService.getDoctorById(id);
  }
}
