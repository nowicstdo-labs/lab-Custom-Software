import { Controller, Post, Get, Param, Body, UseGuards, Res } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { ReportsService } from './reports.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { RolesGuard } from '../common/guards/roles.guard';
import { Roles } from '../common/decorators/roles.decorator';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { Role } from '@prisma/client';
import { Response } from 'express';

@ApiTags('Lab Reports')
@Controller('api/v1/reports')
export class ReportsController {
  constructor(private reportsService: ReportsService) {}

  @Get()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(Role.ADMIN, Role.DOCTOR, Role.LAB_TECHNICIAN, Role.RECEPTIONIST)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'List laboratory reports' })
  getAllReports() {
    return this.reportsService.getAllReports();
  }

  @Post()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(Role.ADMIN, Role.LAB_TECHNICIAN, Role.DOCTOR)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Create new report draft for a test booking' })
  createReportDraft(
    @Body() body: { bookingId: string; parameters?: Array<{ parameterName: string; resultValue: string; unit?: string; referenceRange?: string }> },
  ) {
    return this.reportsService.createReportDraft(body);
  }

  @Post(':id/approve')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(Role.ADMIN, Role.DOCTOR)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Approve or Reject report (Lab Tech prohibited from approving)' })
  approveReport(
    @Param('id') id: string,
    @CurrentUser('id') userId: string,
    @CurrentUser('role') role: Role,
    @Body() body: { approved: boolean; reason?: string },
  ) {
    return this.reportsService.approveReport(id, userId, role, body.approved, body.reason);
  }

  @Get('public/verify/:token')
  @ApiOperation({ summary: 'Public QR Code Report Verification Token Endpoint' })
  verifyPublicReport(@Param('token') token: string) {
    return this.reportsService.verifyPublicReportToken(token);
  }

  @Get(':id/pdf')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Download A4 Printable Medical Report PDF' })
  async downloadPdf(@Param('id') id: string, @Res() res: Response) {
    const pdfBuffer = await this.reportsService.generateReportPdfBuffer(id);
    res.setHeader('Content-Type', 'application/pdf');
    res.setHeader('Content-Disposition', `attachment; filename=report-${id}.pdf`);
    res.send(pdfBuffer);
  }
}
