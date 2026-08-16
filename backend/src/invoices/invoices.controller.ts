import { Controller, Get, Post, Patch, Param, Body, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { InvoicesService } from './invoices.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { RolesGuard } from '../common/guards/roles.guard';
import { Roles } from '../common/decorators/roles.decorator';
import { Role, PaymentStatus } from '@prisma/client';

@ApiTags('Billing & Invoices')
@Controller('api/v1/invoices')
@UseGuards(JwtAuthGuard, RolesGuard)
@ApiBearerAuth()
export class InvoicesController {
  constructor(private invoicesService: InvoicesService) {}

  @Get()
  @Roles(Role.ADMIN, Role.RECEPTIONIST)
  @ApiOperation({ summary: 'List all patient billing invoices and payment statuses' })
  getAllInvoices() {
    return this.invoicesService.getAllInvoices();
  }

  @Post()
  @Roles(Role.ADMIN, Role.RECEPTIONIST)
  @ApiOperation({ summary: 'Generate invoice for a test booking' })
  createInvoice(@Body() body: { bookingId: string }) {
    return this.invoicesService.createInvoiceForBooking(body.bookingId);
  }

  @Patch(':id/payment')
  @Roles(Role.ADMIN, Role.RECEPTIONIST)
  @ApiOperation({ summary: 'Update invoice payment status and record payment transaction' })
  updatePayment(
    @Param('id') id: string,
    @Body() body: { paymentStatus: PaymentStatus; amountPaid?: number },
  ) {
    return this.invoicesService.updatePaymentStatus(id, body.paymentStatus, body.amountPaid);
  }
}
