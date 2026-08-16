import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../database/prisma.service';
import { PaymentStatus } from '@prisma/client';

@Injectable()
export class InvoicesService {
  constructor(private prisma: PrismaService) {}

  async getAllInvoices() {
    return this.prisma.invoice.findMany({
      include: {
        booking: { include: { test: true } },
        patient: { include: { user: true } },
        payments: true,
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async createInvoiceForBooking(bookingId: string) {
    const booking = await this.prisma.booking.findUnique({
      where: { id: bookingId },
      include: { test: true, patient: true },
    });
    if (!booking) {
      throw new NotFoundException('Booking record not found');
    }

    const existing = await this.prisma.invoice.findUnique({ where: { bookingId } });
    if (existing) return existing;

    const invoiceNumber = `ASTH-INV-${Math.floor(10000 + Math.random() * 90000)}`;

    return this.prisma.invoice.create({
      data: {
        invoiceNumber,
        bookingId: booking.id,
        patientId: booking.patientId,
        totalAmount: booking.price,
        netAmount: booking.price,
        paymentStatus: PaymentStatus.PENDING,
        items: {
          create: [
            { description: booking.test.testName, amount: booking.price },
          ],
        },
      },
      include: { items: true, patient: { include: { user: true } } },
    });
  }

  async updatePaymentStatus(id: string, paymentStatus: PaymentStatus, amountPaid?: number) {
    const invoice = await this.prisma.invoice.findUnique({ where: { id } });
    if (!invoice) {
      throw new NotFoundException('Invoice record not found');
    }

    if (amountPaid && amountPaid > 0) {
      await this.prisma.payment.create({
        data: {
          paymentId: `PAY-${Math.floor(10000 + Math.random() * 90000)}`,
          invoiceId: invoice.id,
          amount: amountPaid,
          paymentMethod: 'CASH / CARD',
          status: PaymentStatus.PAID,
        },
      });
    }

    return this.prisma.invoice.update({
      where: { id },
      data: { paymentStatus },
      include: { payments: true },
    });
  }
}
