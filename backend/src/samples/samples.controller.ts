import { Controller, Get, Patch, Param, Body, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { SamplesService } from './samples.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { RolesGuard } from '../common/guards/roles.guard';
import { Roles } from '../common/decorators/roles.decorator';
import { Role, SampleStage } from '@prisma/client';

@ApiTags('Lab Samples')
@Controller('api/v1/samples')
@UseGuards(JwtAuthGuard, RolesGuard)
@ApiBearerAuth()
export class SamplesController {
  constructor(private samplesService: SamplesService) {}

  @Get()
  @Roles(Role.ADMIN, Role.RECEPTIONIST, Role.LAB_TECHNICIAN, Role.DOCTOR)
  @ApiOperation({ summary: 'List laboratory samples and collection stages' })
  getAllSamples() {
    return this.samplesService.getAllSamples();
  }

  @Get('lookup/:token')
  @Roles(Role.ADMIN, Role.RECEPTIONIST, Role.LAB_TECHNICIAN, Role.DOCTOR)
  @ApiOperation({ summary: 'Lookup sample details by Barcode or Token' })
  lookupBarcode(@Param('token') token: string) {
    return this.samplesService.lookupBarcode(token);
  }

  @Patch(':id/stage')
  @Roles(Role.ADMIN, Role.LAB_TECHNICIAN, Role.RECEPTIONIST)
  @ApiOperation({ summary: 'Advance sample stage (SAMPLE_COLLECTED -> PROCESSING -> TESTING -> COMPLETED)' })
  updateSampleStage(@Param('id') id: string, @Body() body: { stage: SampleStage }) {
    return this.samplesService.updateSampleStage(id, body.stage);
  }
}
