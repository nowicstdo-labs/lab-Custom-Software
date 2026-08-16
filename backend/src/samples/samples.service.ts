import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../database/prisma.service';
import { SampleStage } from '@prisma/client';

@Injectable()
export class SamplesService {
  constructor(private prisma: PrismaService) {}

  async getAllSamples() {
    return this.prisma.sample.findMany({
      include: {
        booking: { include: { test: true } },
        patient: { include: { user: true } },
      },
      orderBy: { collectionTime: 'desc' },
    });
  }

  async lookupBarcode(barcodeToken: string) {
    const sample = await this.prisma.sample.findFirst({
      where: { OR: [{ barcodeToken }, { sampleId: barcodeToken }] },
      include: {
        booking: { include: { test: { include: { parameters: true } } } },
        patient: { include: { user: true } },
        testResults: true,
      },
    });
    if (!sample) {
      throw new NotFoundException('Sample barcode token not found');
    }
    return sample;
  }

  async updateSampleStage(id: string, stage: SampleStage) {
    const sample = await this.prisma.sample.findUnique({ where: { id } });
    if (!sample) {
      throw new NotFoundException('Sample not found');
    }
    return this.prisma.sample.update({
      where: { id },
      data: { stage },
      include: { booking: { include: { test: true } }, patient: { include: { user: true } } },
    });
  }
}
