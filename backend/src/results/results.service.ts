import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../database/prisma.service';
import { ResultFlag } from '@prisma/client';
import * as math from 'mathjs';

@Injectable()
export class ResultsService {
  constructor(private prisma: PrismaService) {}

  async submitTestResults(body: { sampleId: string; results: Array<{ parameterId: string; resultValue: string }> }) {
    const sample = await this.prisma.sample.findUnique({
      where: { id: body.sampleId },
      include: { booking: { include: { test: true } } },
    });

    if (!sample) {
      throw new NotFoundException('Sample record not found');
    }

    const savedResults = [];

    for (const r of body.results) {
      const parameter = await this.prisma.testParameter.findUnique({ where: { id: r.parameterId } });
      let flag: ResultFlag = ResultFlag.NORMAL;

      if (parameter && parameter.minVal !== null && parameter.maxVal !== null) {
        const val = parseFloat(r.resultValue);
        if (!isNaN(val)) {
          if (val < parameter.minVal) flag = ResultFlag.LOW;
          if (val > parameter.maxVal) flag = ResultFlag.HIGH;
        }
      }

      const res = await this.prisma.testResult.create({
        data: {
          sampleId: sample.id,
          parameterId: r.parameterId,
          resultValue: r.resultValue,
          statusFlag: flag,
        },
        include: { parameter: true },
      });
      savedResults.push(res);
    }

    // Evaluate associated formulas for the test automatically if available
    const formulas = await this.prisma.formula.findMany({
      where: { targetTestId: sample.booking.testId, isActive: true },
    });

    const valueMap: Record<string, number> = {};
    for (const r of savedResults) {
      const num = parseFloat(r.resultValue);
      if (!isNaN(num)) {
        valueMap[r.parameter.parameterName] = num;
      }
    }

    for (const formula of formulas) {
      try {
        const calculated = math.evaluate(formula.expression, valueMap);
        if (typeof calculated === 'number') {
          // Find or create calculated parameter result
          const param = await this.prisma.testParameter.findFirst({
            where: { testId: sample.booking.testId, parameterName: formula.formulaName },
          });
          if (param) {
            await this.prisma.testResult.create({
              data: {
                sampleId: sample.id,
                parameterId: param.id,
                resultValue: calculated.toFixed(2),
                statusFlag: ResultFlag.NORMAL,
              },
            });
          }
        }
      } catch (_) {}
    }

    return { success: true, count: savedResults.length, sampleId: sample.id };
  }

  async getResultsBySample(sampleId: string) {
    return this.prisma.testResult.findMany({
      where: { sampleId },
      include: { parameter: true },
      orderBy: { parameter: { displayOrder: 'asc' } },
    });
  }
}
