import { Injectable, BadRequestException, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../database/prisma.service';

@Injectable()
export class AppointmentsService {
  constructor(private prisma: PrismaService) {}

  async createAppointment(userId: string, dto: { doctorId: string; date: string; timeSlot: string; symptoms?: string }) {
    let patient = await this.prisma.patientProfile.findUnique({ where: { userId } });
    if (!patient) {
      patient = await this.prisma.patientProfile.create({
        data: { userId, patientId: `ASTH-P-${Math.floor(100000 + Math.random() * 900000)}` },
      });
    }

    const doctor = await this.prisma.doctorProfile.findFirst({
      where: { OR: [{ id: dto.doctorId }, { doctorId: dto.doctorId }] },
    });
    if (!doctor) {
      throw new NotFoundException('Doctor profile not found');
    }

    // Capacity enforcement (max 10 patients per slot)
    return this.prisma.$transaction(async (tx) => {
      let slot = await tx.appointmentSlot.findUnique({
        where: { date_timeSlot: { date: dto.date, timeSlot: dto.timeSlot } },
      });
      if (!slot) {
        slot = await tx.appointmentSlot.create({
          data: { date: dto.date, timeSlot: dto.timeSlot, maxCapacity: 10, currentBookings: 0 },
        });
      }
      if (slot.currentBookings >= slot.maxCapacity) {
        throw new BadRequestException(`Time slot ${dto.timeSlot} on ${dto.date} is full.`);
      }

      await tx.appointmentSlot.update({
        where: { id: slot.id },
        data: { currentBookings: { increment: 1 } },
      });

      return tx.appointment.create({
        data: {
          appointmentId: `ASTH-APT-${Math.floor(1000 + Math.random() * 9000)}`,
          patientId: patient.id,
          doctorId: doctor.id,
          appointmentDate: dto.date,
          timeSlot: dto.timeSlot,
          symptoms: dto.symptoms,
        },
        include: { doctor: { include: { user: true } }, patient: { include: { user: true } } },
      });
    });
  }

  async getMyAppointments(userId: string) {
    const patient = await this.prisma.patientProfile.findUnique({ where: { userId } });
    if (!patient) return [];
    return this.prisma.appointment.findMany({
      where: { patientId: patient.id },
      include: { doctor: { include: { user: true } } },
      orderBy: { createdAt: 'desc' },
    });
  }

  async getAllAppointments() {
    return this.prisma.appointment.findMany({
      include: { doctor: { include: { user: true } }, patient: { include: { user: true } } },
      orderBy: { createdAt: 'desc' },
    });
  }
}
