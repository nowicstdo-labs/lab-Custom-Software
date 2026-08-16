import { Controller, Get, Patch, Param, Body, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { PatientsService } from './patients.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { RolesGuard } from '../common/guards/roles.guard';
import { Roles } from '../common/decorators/roles.decorator';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { Role } from '@prisma/client';

@ApiTags('Patient Management')
@Controller('api/v1/patients')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class PatientsController {
  constructor(private patientsService: PatientsService) {}

  @Get('me')
  @ApiOperation({ summary: 'Get authenticated patient profile and medical history' })
  getMyProfile(@CurrentUser('id') userId: string) {
    return this.patientsService.getMyProfile(userId);
  }

  @Patch('me')
  @ApiOperation({ summary: 'Update authenticated patient profile' })
  updateMyProfile(@CurrentUser('id') userId: string, @Body() body: any) {
    return this.patientsService.updateMyProfile(userId, body);
  }

  @Get('search')
  @UseGuards(RolesGuard)
  @Roles(Role.ADMIN, Role.RECEPTIONIST, Role.LAB_TECHNICIAN, Role.DOCTOR)
  @ApiOperation({ summary: 'Search patients by name, patientId, or phone' })
  searchPatients(@Query('q') query: string) {
    return this.patientsService.searchPatients(query || '');
  }

  @Get(':id')
  @UseGuards(RolesGuard)
  @Roles(Role.ADMIN, Role.RECEPTIONIST, Role.LAB_TECHNICIAN, Role.DOCTOR)
  @ApiOperation({ summary: 'Get detailed patient profile by ID' })
  getPatientById(@Param('id') id: string) {
    return this.patientsService.getPatientById(id);
  }
}
