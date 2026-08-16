import { Controller, Get, Post, Patch, Param, Body, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { TestsService } from './tests.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { RolesGuard } from '../common/guards/roles.guard';
import { Roles } from '../common/decorators/roles.decorator';
import { Role } from '@prisma/client';

@ApiTags('Test Catalog & Test-Specific Formula Engine')
@Controller('api/v1/tests')
export class TestsController {
  constructor(private testsService: TestsService) {}

  @Get()
  @ApiOperation({ summary: 'Get list of active diagnostic tests and parameters' })
  getAllTests() {
    return this.testsService.getAllTests();
  }

  @Post()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(Role.ADMIN)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Admin create new diagnostic test' })
  createTest(@Body() body: { testId: string; testName: string; category: string; price: number; description?: string; sampleType?: string; tat?: string }) {
    return this.testsService.createTest(body);
  }

  @Patch(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(Role.ADMIN)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Admin update test details, price, discount, or status' })
  updateTest(@Param('id') id: string, @Body() body: any) {
    return this.testsService.updateTest(id, body);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get detailed diagnostic test definition by Test ID' })
  getTestById(@Param('id') id: string) {
    return this.testsService.getTestById(id);
  }

  @Get(':id/parameters')
  @ApiOperation({ summary: 'Get test-specific parameters and reference ranges' })
  getTestParameters(@Param('id') id: string) {
    return this.testsService.getTestParameters(id);
  }

  @Get(':id/formula')
  @ApiOperation({ summary: 'Get test-specific formula calculation configuration (CALCULATED vs MANUAL)' })
  getTestFormula(@Param('id') id: string) {
    return this.testsService.getTestFormula(id);
  }

  @Post(':id/calculate')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Calculate test-specific result using authorized test formula' })
  calculateResult(@Param('id') id: string, @Body() body: { inputValues: Record<string, number> }) {
    return this.testsService.calculateTestResult(id, body.inputValues);
  }
}
