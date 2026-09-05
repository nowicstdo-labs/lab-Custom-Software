import { Injectable, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../database/prisma.service';
import * as math from 'mathjs';

@Injectable()
export class FormulasService {
  constructor(private prisma: PrismaService) {}

  evaluateFormula(expression: string, variables: Record<string, number>): number {
    try {
      // Validate restricted mathematical expression (only math symbols and parameter names)
      const sanitized = expression.replace(/[^a-zA-Z0-9_\s\+\-\*\/\(\)\.]/g, '');
      if (sanitized !== expression) {
        throw new BadRequestException('Formula contains invalid or unsafe characters');
      }
      const dangerousKeywords = ['eval', 'require', 'import', 'function', 'console', 'window', 'process', 'global', 'constructor', 'prototype', '__proto__', 'this'];
      const hasDangerousKeyword = dangerousKeywords.some(kw => new RegExp(`\\b${kw}\\b`).test(expression));
      if (hasDangerousKeyword) {
        throw new BadRequestException('Formula contains restricted keywords');
      }

      const compiled = math.compile(sanitized);
      const result = compiled.evaluate(variables);

      if (typeof result !== 'number' || !isFinite(result)) {
        throw new BadRequestException('Formula evaluation resulted in division by zero or infinity');
      }

      return parseFloat(result.toFixed(2));
    } catch (err) {
      throw new BadRequestException(`Formula evaluation failed: ${err.message}`);
    }
  }

  async getAllFormulas() {
    return this.prisma.formula.findMany({ include: { test: true } });
  }
}
