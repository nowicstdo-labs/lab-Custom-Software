import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../database/prisma.service';
import * as math from 'mathjs';

export enum CalculationType {
  CALCULATED = 'CALCULATED',
  MANUAL = 'MANUAL',
  FORMULA_MISSING = 'FORMULA_MISSING',
}

@Injectable()
export class TestsService {
  constructor(private prisma: PrismaService) {}

  async getAllTests() {
    return this.prisma.test.findMany({
      where: { isActive: true },
      include: { parameters: { orderBy: { displayOrder: 'asc' } }, formulas: true },
      orderBy: { testName: 'asc' },
    });
  }

  async getTestById(id: string) {
    const test = await this.prisma.test.findFirst({
      where: { OR: [{ id }, { testId: id }] },
      include: { parameters: { orderBy: { displayOrder: 'asc' } }, formulas: true },
    });
    if (!test) throw new NotFoundException(`Diagnostic test with ID ${id} not found`);
    return test;
  }

  async getTestParameters(testId: string) {
    const test = await this.getTestById(testId);
    return test.parameters;
  }

  async getTestFormula(testId: string) {
    const test = await this.getTestById(testId);
    const formula = await this.prisma.formula.findFirst({
      where: { targetTestId: test.id, isActive: true },
    });

    if (!formula) {
      return {
        testId: test.testId,
        testName: test.testName,
        calculationType: CalculationType.MANUAL,
        formula: null,
        message: 'Manual test entry — No dynamic formula configured',
      };
    }

    return {
      testId: test.testId,
      testName: test.testName,
      calculationType: CalculationType.CALCULATED,
      formula: {
        id: formula.formulaId,
        name: formula.formulaName,
        expression: formula.expression,
        requiredParameters: formula.parameters.split(','),
      },
    };
  }

  async calculateTestResult(testId: string, inputValues: Record<string, number>) {
    const formulaConfig = await this.getTestFormula(testId);
    if (formulaConfig.calculationType === CalculationType.MANUAL || !formulaConfig.formula) {
      throw new BadRequestException(`Test ${testId} is configured for manual entry and does not have a dynamic formula.`);
    }

    const { expression, requiredParameters } = formulaConfig.formula;

    for (const param of requiredParameters) {
      if (inputValues[param] === undefined || inputValues[param] === null) {
        throw new BadRequestException(`Missing required parameter '${param}' for test formula calculation`);
      }
    }

    try {
      const compiled = math.compile(expression);
      const result = compiled.evaluate(inputValues);

      if (typeof result !== 'number' || !isFinite(result)) {
        throw new BadRequestException('Formula calculation resulted in division by zero or invalid number');
      }

      return {
        testId,
        testName: formulaConfig.testName,
        formulaName: formulaConfig.formula.name,
        expression,
        calculatedValue: parseFloat(result.toFixed(2)),
        evaluatedAt: new Date().toISOString(),
      };
    } catch (err) {
      throw new BadRequestException(`Test calculation error: ${err.message}`);
    }
  }

  async createTest(dto: { testId: string; testName: string; category: string; price: number; description?: string; preparationInfo?: string }) {
    return this.prisma.test.create({
      data: {
        testId: dto.testId,
        testName: dto.testName,
        category: dto.category,
        price: dto.price,
        description: dto.description || 'Laboratory diagnostic test.',
        preparationInfo: dto.preparationInfo || 'Fasting for 8-10 hours may be required.',
        isActive: true,
      },
    });
  }

  async updateTest(id: string, dto: any) {
    const test = await this.prisma.test.findFirst({
      where: { OR: [{ id }, { testId: id }] },
    });
    if (!test) throw new NotFoundException(`Test with ID ${id} not found`);

    return this.prisma.test.update({
      where: { id: test.id },
      data: {
        testName: dto.testName,
        category: dto.category,
        price: dto.price !== undefined ? parseFloat(dto.price.toString()) : undefined,
        description: dto.description,
        preparationInfo: dto.preparationInfo,
        isActive: dto.isActive !== undefined ? Boolean(dto.isActive) : undefined,
      },
    });
  }
}
