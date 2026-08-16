import { Module } from '@nestjs/common';
import { SamplesController } from './samples.controller';
import { SamplesService } from './samples.service';
import { DatabaseModule } from '../database/database.module';

@Module({
  imports: [DatabaseModule],
  controllers: [SamplesController],
  providers: [SamplesService],
  exports: [SamplesService],
})
export class SamplesModule {}
