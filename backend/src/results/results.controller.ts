import { Controller, Post, Get, Param, Body, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { ResultsService } from './results.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { RolesGuard } from '../common/guards/roles.guard';
import { Roles } from '../common/decorators/roles.decorator';
import { Role } from '@prisma/client';

@ApiTags('Test Results Entry & Dynamic Calculation')
@Controller('api/v1/results')
@UseGuards(JwtAuthGuard, RolesGuard)
@ApiBearerAuth()
export class ResultsController {
  constructor(private resultsService: ResultsService) {}

  @Post()
  @Roles(Role.ADMIN, Role.LAB_TECHNICIAN)
  @ApiOperation({ summary: 'Submit laboratory test parameter values and evaluate dynamic formulas' })
  submitTestResults(
    @Body() body: { sampleId: string; results: Array<{ parameterId: string; resultValue: string }> },
  ) {
    return this.resultsService.submitTestResults(body);
  }

  @Get('sample/:sampleId')
  @Roles(Role.ADMIN, Role.LAB_TECHNICIAN, Role.DOCTOR, Role.RECEPTIONIST, Role.PATIENT)
  @ApiOperation({ summary: 'Get evaluated test parameter results by Sample ID' })
  getResultsBySample(@Param('sampleId') sampleId: string) {
    return this.resultsService.getResultsBySample(sampleId);
  }
}
