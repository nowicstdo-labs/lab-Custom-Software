import { Injectable, BadRequestException, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../database/prisma.service';
import { CreateBookingDto } from './dto/booking.dto';

@Injectable()
export class BookingsService {
  constructor(private prisma: PrismaService) {}

  async createBooking(userId: string, dto: CreateBookingDto) {
    let patient = await this.prisma.patientProfile.findUnique({ where: { userId } });
    if (!patient) {
      const user = await this.prisma.user.findUnique({ where: { id: userId } });
      if (!user) {
        throw new NotFoundException('User account not found');
      }
      patient = await this.prisma.patientProfile.create({
        data: {
          userId,
          patientId: `ASTH-P-${Math.floor(100000 + Math.random() * 900000)}`,
        },
      });
    }

    const test = await this.prisma.test.findFirst({
      where: { OR: [{ id: dto.testId }, { testId: dto.testId }] },
    });
    if (!test) {
      throw new NotFoundException('Diagnostic test not found');
    }

    // Transactional slot capacity check (Max 10 Patients per Slot)
    return this.prisma.$transaction(async (tx) => {
      let slot = await tx.appointmentSlot.findUnique({
        where: { date_timeSlot: { date: dto.appointmentDate, timeSlot: dto.timeSlot } },
      });

      if (!slot) {
        slot = await tx.appointmentSlot.create({
          data: { date: dto.appointmentDate, timeSlot: dto.timeSlot, maxCapacity: 10, currentBookings: 0 },
        });
      }

      if (slot.currentBookings >= slot.maxCapacity) {
        throw new BadRequestException(`Time slot ${dto.timeSlot} on ${dto.appointmentDate} is FULL (Maximum capacity of 10 patients reached).`);
      }

      // Increment current bookings
      await tx.appointmentSlot.update({
        where: { id: slot.id },
        data: { currentBookings: { increment: 1 } },
      });

      // Create Booking Record
      const booking = await tx.booking.create({
        data: {
          bookingId: `ASTH-BK-${Math.floor(1000 + Math.random() * 9000)}`,
          patientId: patient.id,
          testId: test.id,
          appointmentDate: dto.appointmentDate,
          timeSlot: dto.timeSlot,
          price: dto.price,
        },
        include: { test: true, patient: { include: { user: true } } },
      });

      return booking;
    }).catch((error) => {
      throw new BadRequestException(`Booking failed: ${error instanceof Error ? error.message : 'Unknown error'}`);
    });
  }

  async getPatientBookings(userId: string) {
    const patient = await this.prisma.patientProfile.findUnique({ where: { userId } });
    if (!patient) return [];
    return this.prisma.booking.findMany({
      where: { patientId: patient.id },
      include: { test: true, samples: true, report: true },
      orderBy: { createdAt: 'desc' },
    });
  }

  async getAllBookings() {
    return this.prisma.booking.findMany({
      include: { test: true, patient: { include: { user: true } }, samples: true, report: true },
      orderBy: { createdAt: 'desc' },
    });
  }
}
