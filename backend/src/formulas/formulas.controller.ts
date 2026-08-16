import { Controller, Post, Get, Body, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { FormulasService } from './formulas.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { RolesGuard } from '../common/guards/roles.guard';
import { Roles } from '../common/decorators/roles.decorator';
import { Role } from '@prisma/client';

@ApiTags('Formula Engine')
@Controller('api/v1/formulas')
@UseGuards(JwtAuthGuard, RolesGuard)
@ApiBearerAuth()
export class FormulasController {
  constructor(private formulasService: FormulasService) {}

  @Get()
  @Roles(Role.ADMIN, Role.LAB_TECHNICIAN)
  @ApiOperation({ summary: 'Get list of active diagnostic formulas' })
  getFormulas() {
    return this.formulasService.getAllFormulas();
  }

  @Post('evaluate')
  @Roles(Role.LAB_TECHNICIAN, Role.ADMIN)
  @ApiOperation({ summary: 'Evaluate mathematical formula with parameters' })
  evaluate(@Body() body: { expression: string; variables: Record<string, number> }) {
    const value = this.formulasService.evaluateFormula(body.expression, body.variables);
    return { expression: body.expression, result: value };
  }
}
