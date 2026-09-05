import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../database/prisma.service';
import * as argon2 from 'argon2';

@Injectable()
export class DoctorsService {
  constructor(private prisma: PrismaService) {}

  async getAllDoctors() {
    return this.prisma.doctorProfile.findMany({
      include: { user: true },
      orderBy: { createdAt: 'desc' },
    });
  }

  async getDoctorById(id: string) {
    const doctor = await this.prisma.doctorProfile.findFirst({
      where: { OR: [{ id }, { doctorId: id }, { userId: id }] },
      include: { user: true, appointments: true, reports: true },
    });
    if (!doctor) {
      throw new NotFoundException('Doctor profile not found');
    }
    return doctor;
  }

  async getDoctorAppointments(userId: string) {
    const doctor = await this.prisma.doctorProfile.findUnique({ where: { userId } });
    if (!doctor) return [];
    return this.prisma.appointment.findMany({
      where: { doctorId: doctor.id },
      include: { patient: { include: { user: true } } },
      orderBy: { createdAt: 'desc' },
    });
  }

  async createDoctor(dto: { name: string; specialization: string; qualification?: string; experienceYears?: number; consultationFee?: number; password?: string }) {
    const doctorId = `DOC-${Math.floor(1000 + Math.random() * 9000)}`;
    const defaultPassword = dto.password || 'Doctor@123';
    const passwordHash = await argon2.hash(defaultPassword);
    const user = await this.prisma.user.create({
      data: {
        name: dto.name,
        email: `doctor.${doctorId.toLowerCase()}@astha.com`,
        phone: `+91 ${Math.floor(9000000000 + Math.random() * 999999999)}`,
        passwordHash,
        role: 'DOCTOR',
      },
    });

    return this.prisma.doctorProfile.create({
      data: {
        doctorId,
        userId: user.id,
        specialization: dto.specialization,
        qualification: dto.qualification || 'MBBS, MD',
        experienceYears: dto.experienceYears ? parseInt(dto.experienceYears.toString(), 10) : 8,
        consultationFee: dto.consultationFee ? parseFloat(dto.consultationFee.toString().replace(/[^0-9.]/g, '')) : 500,
      },
      include: { user: true },
    });
  }

  async updateDoctor(id: string, dto: any) {
    const doctor = await this.prisma.doctorProfile.findFirst({
      where: { OR: [{ id }, { doctorId: id }] },
    });
    if (!doctor) throw new NotFoundException('Doctor profile not found');

    if (dto.name) {
      await this.prisma.user.update({
        where: { id: doctor.userId },
        data: { name: dto.name },
      });
    }

    return this.prisma.doctorProfile.update({
      where: { id: doctor.id },
      data: {
        specialization: dto.specialization,
        qualification: dto.qualification,
        experienceYears: dto.experienceYears !== undefined ? parseInt(dto.experienceYears.toString(), 10) : undefined,
        consultationFee: dto.consultationFee !== undefined ? parseFloat(dto.consultationFee.toString().replace(/[^0-9.]/g, '')) : undefined,
      },
      include: { user: true },
    });
  }
}
