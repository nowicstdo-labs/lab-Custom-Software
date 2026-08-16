import { Injectable, OnModuleInit, OnModuleDestroy } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';

@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit, OnModuleDestroy {
  async onModuleInit() {
    try {
      await this.$connect();
      console.log('✅ Connected to PostgreSQL Database via Prisma ORM');
    } catch (e: any) {
      console.warn('⚠️ Warning: Prisma DB connection failed or offline:', e?.message || e);
    }
  }

  async onModuleDestroy() {
    try {
      await this.$disconnect();
    } catch (_) {}
  }
}
