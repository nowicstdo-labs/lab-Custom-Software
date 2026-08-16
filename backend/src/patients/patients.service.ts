import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../database/prisma.service';

@Injectable()
export class PatientsService {
  constructor(private prisma: PrismaService) {}

  async getMyProfile(userId: string) {
    const patient = await this.prisma.patientProfile.findUnique({
      where: { userId },
      include: {
        user: true,
        bookings: { include: { test: true } },
        appointments: { include: { doctor: { include: { user: true } } } },
        reports: true,
        invoices: true,
      },
    });
    if (!patient) {
      throw new NotFoundException('Patient profile not found');
    }
    return patient;
  }

  async updateMyProfile(userId: string, data: any) {
    const patient = await this.prisma.patientProfile.findUnique({ where: { userId } });
    if (!patient) {
      throw new NotFoundException('Patient profile not found');
    }
    return this.prisma.patientProfile.update({
      where: { id: patient.id },
      data: {
        dob: data.dob,
        gender: data.gender,
        bloodGroup: data.bloodGroup,
        address: data.address,
        alternateNumber: data.alternateNumber,
        emergencyName: data.emergencyName,
        emergencyPhone: data.emergencyPhone,
      },
      include: { user: true },
    });
  }

  async searchPatients(query: string) {
    const term = query ? query.trim().toLowerCase() : '';
    return this.prisma.patientProfile.findMany({
      where: {
        OR: [
          { patientId: { contains: term, mode: 'insensitive' } },
          { user: { name: { contains: term, mode: 'insensitive' } } },
          { user: { phone: { contains: term, mode: 'insensitive' } } },
        ],
      },
      include: { user: true },
      take: 20,
    });
  }

  async getPatientById(id: string) {
    const patient = await this.prisma.patientProfile.findFirst({
      where: { OR: [{ id }, { patientId: id }] },
      include: { user: true, bookings: { include: { test: true } }, reports: true },
    });
    if (!patient) {
      throw new NotFoundException('Patient not found');
    }
    return patient;
  }
}
