import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { ThrottlerModule } from '@nestjs/throttler';
import { DatabaseModule } from './database/database.module';
import { AuthModule } from './auth/auth.module';
import { StaffModule } from './staff/staff.module';
import { TestsModule } from './tests/tests.module';
import { BookingsModule } from './bookings/bookings.module';
import { FormulasModule } from './formulas/formulas.module';
import { ReportsModule } from './reports/reports.module';
import { AuditLogsModule } from './audit-logs/audit-logs.module';
import { PatientsModule } from './patients/patients.module';
import { DoctorsModule } from './doctors/doctors.module';
import { AppointmentsModule } from './appointments/appointments.module';
import { SamplesModule } from './samples/samples.module';
import { ResultsModule } from './results/results.module';
import { InvoicesModule } from './invoices/invoices.module';
import { NotificationsModule } from './notifications/notifications.module';
import { AdminModule } from './admin/admin.module';
import { AppController } from './app.controller';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    ThrottlerModule.forRoot([{ ttl: 60000, limit: 100 }]),
    DatabaseModule,
    AuthModule,
    StaffModule,
    TestsModule,
    BookingsModule,
    FormulasModule,
    ReportsModule,
    AuditLogsModule,
    PatientsModule,
    DoctorsModule,
    AppointmentsModule,
    SamplesModule,
    ResultsModule,
    InvoicesModule,
    NotificationsModule,
    AdminModule,
  ],
  controllers: [AppController],
})
export class AppModule {}
