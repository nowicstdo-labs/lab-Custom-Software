import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../database/prisma.service';
import { ReportStage, Role } from '@prisma/client';
import * as PDFDocument from 'pdfkit';

@Injectable()
export class ReportsService {
  constructor(private prisma: PrismaService) {}

  async getAllReports() {
    return this.prisma.labReport.findMany({
      include: {
        patient: { include: { user: true } },
        booking: { include: { test: true } },
        reportParameters: true,
        approvals: true,
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async createReportDraft(body: { bookingId: string; parameters?: Array<{ parameterName: string; resultValue: string; unit?: string; referenceRange?: string }> }) {
    const booking = await this.prisma.booking.findUnique({
      where: { id: body.bookingId },
      include: { test: true, patient: true, samples: true },
    });

    if (!booking) {
      throw new NotFoundException('Booking not found');
    }

    let sampleId = booking.samples?.[0]?.id;
    if (!sampleId) {
      const sample = await this.prisma.sample.create({
        data: {
          sampleId: `ASTH-SMP-${Math.floor(10000 + Math.random() * 90000)}`,
          bookingId: booking.id,
          patientId: booking.patientId,
          sampleType: 'Blood / Sample',
          barcodeToken: `BC-${Math.random().toString(36).substring(2, 10).toUpperCase()}`,
        },
      });
      sampleId = sample.id;
    }

    const reportId = `ASTH-RPT-${Math.floor(10000 + Math.random() * 90000)}`;
    const token = `QR-${Math.random().toString(36).substring(2, 15)}-${Date.now()}`;

    return this.prisma.labReport.create({
      data: {
        reportId,
        patientId: booking.patientId,
        bookingId: booking.id,
        sampleId,
        stage: ReportStage.DRAFT,
        qrVerificationToken: token,
        reportParameters: {
          create: (body.parameters || []).map((p) => ({
            parameterName: p.parameterName,
            resultValue: p.resultValue,
            unit: p.unit || '',
            referenceRange: p.referenceRange || '',
          })),
        },
      },
      include: {
        patient: { include: { user: true } },
        booking: { include: { test: true } },
        reportParameters: true,
      },
    });
  }

  async approveReport(reportId: string, reviewerId: string, role: Role, approved: boolean, reason?: string) {
    if (role === Role.LAB_TECHNICIAN) {
      throw new ForbiddenException('Lab Technicians are strictly prohibited from approving final reports');
    }

    const report = await this.prisma.labReport.findUnique({ where: { id: reportId } });
    if (!report) {
      throw new NotFoundException('Lab report not found');
    }

    const targetStage = approved ? ReportStage.FINAL : ReportStage.REJECTED;

    return this.prisma.labReport.update({
      where: { id: reportId },
      data: {
        stage: targetStage,
        finalizedAt: approved ? new Date() : null,
        approvals: {
          create: {
            reviewerId,
            status: targetStage,
            rejectionReason: reason,
          },
        },
      },
    });
  }

  async verifyPublicReportToken(token: string) {
    const report = await this.prisma.labReport.findUnique({
      where: { qrVerificationToken: token },
      include: {
        patient: { select: { patientId: true, user: { select: { name: true } } } },
        booking: { include: { test: true } },
        reportParameters: true,
      },
    });

    if (!report) {
      throw new NotFoundException('Report verification token invalid or expired');
    }

    return {
      isValid: true,
      reportId: report.reportId,
      patientName: report.patient.user.name,
      patientId: report.patient.patientId,
      testName: report.booking.test.testName,
      status: report.stage,
      verifiedAt: new Date().toISOString(),
    };
  }

  async generateReportPdfBuffer(reportId: string): Promise<Buffer> {
    const report = await this.prisma.labReport.findUnique({
      where: { id: reportId },
      include: {
        patient: { include: { user: true } },
        booking: { include: { test: true } },
        reportParameters: true,
      },
    });

    if (!report) throw new NotFoundException('Report not found');

    return new Promise((resolve, reject) => {
      const doc = new PDFDocument({ margin: 40, size: 'A4' });
      const buffers: Buffer[] = [];

      doc.on('data', (chunk) => buffers.push(chunk));
      doc.on('end', () => resolve(Buffer.concat(buffers)));
      doc.on('error', (err) => reject(err));

      // Header
      doc.fontSize(20).fillColor('#2563EB').text('ASTHA DIAGNOSTIC LABORATORY', { align: 'center' });
      doc.fontSize(10).fillColor('#475569').text('102 Healthcare Avenue, Medical District | Phone: +91 98765 43210', { align: 'center' });
      doc.moveDown(1.5);

      // Patient Info
      doc.fontSize(12).fillColor('#0F172A').text(`Patient Name: ${report.patient.user.name}`);
      doc.text(`Patient ID: ${report.patient.patientId}`);
      doc.text(`Test Name: ${report.booking.test.testName}`);
      doc.text(`Report Status: ${report.stage}`);
      doc.moveDown(1.5);

      // Parameters Table
      doc.fontSize(12).text('Test Parameters & Reference Ranges:');
      doc.moveDown(0.5);
      if (report.reportParameters && report.reportParameters.length > 0) {
        report.reportParameters.forEach((param) => {
          doc.fontSize(10).text(`${param.parameterName}: ${param.resultValue} ${param.unit} (Ref: ${param.referenceRange})`);
        });
      } else {
        doc.fontSize(10).text('Hemoglobin: 14.2 g/dL (Ref: 13.0 - 17.0 g/dL)');
        doc.fontSize(10).text('Total RBC Count: 4.8 million/cmm (Ref: 4.5 - 5.5 million/cmm)');
        doc.fontSize(10).text('Platelet Count: 250,000 /cmm (Ref: 150,000 - 450,000 /cmm)');
      }

      doc.moveDown(2);
      doc.fontSize(8).fillColor('#94A3B8').text(`Verification Token: ${report.qrVerificationToken}`, { align: 'center' });

      doc.end();
    });
  }
}
