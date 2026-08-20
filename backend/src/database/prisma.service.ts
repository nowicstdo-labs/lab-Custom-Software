import { Injectable, OnModuleInit, OnModuleDestroy, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PrismaClient } from '@prisma/client';

@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(PrismaService.name);

  constructor(configService: ConfigService) {
    const dbUrl = configService.get<string>('DATABASE_URL') || process.env.DATABASE_URL;
    const isProduction = configService.get<string>('NODE_ENV') === 'production' || process.env.NODE_ENV === 'production';

    if (!dbUrl) {
      console.error('❌ CRITICAL ERROR: DATABASE_URL environment variable is missing!');
      console.error('👉 Please set DATABASE_URL in Render Dashboard -> Environment Variables tab.');
    } else if (isProduction && (dbUrl.includes('localhost') || dbUrl.includes('127.0.0.1'))) {
      console.error('❌ CRITICAL ERROR: DATABASE_URL is pointing to localhost in PRODUCTION!');
      console.error('👉 Replace localhost with your production Cloud PostgreSQL connection string in Render Dashboard.');
    }

    super({
      datasources: dbUrl
        ? {
            db: {
              url: dbUrl,
            },
          }
        : undefined,
    });
  }

  async onModuleInit() {
    try {
      await this.$connect();
      this.logger.log('✅ Connected to PostgreSQL Database via Prisma ORM');
    } catch (e: any) {
      this.logger.error('❌ Prisma DB connection failed: ' + (e?.message || e));
    }
  }

  async onModuleDestroy() {
    try {
      await this.$disconnect();
    } catch (_) {}
  }
}


