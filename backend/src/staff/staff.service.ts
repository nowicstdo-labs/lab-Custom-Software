import { Injectable, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../database/prisma.service';
import { CreateStaffDto } from './dto/staff.dto';
import * as argon2 from 'argon2';

@Injectable()
export class StaffService {
  constructor(private prisma: PrismaService) {}

  async createStaff(dto: CreateStaffDto) {
    const existing = await this.prisma.user.findUnique({ where: { email: dto.email.toLowerCase() } });
    if (existing) {
      throw new BadRequestException('A user with this email already exists');
    }

    const passwordHash = await argon2.hash(dto.password);
    const user = await this.prisma.user.create({
      data: {
        name: dto.name,
        email: dto.email.toLowerCase(),
        passwordHash,
        role: dto.role,
        phone: dto.phone,
        staffProfile: {
          create: {
            employeeId: `EMP-${Math.floor(1000 + Math.random() * 9000)}`,
            designation: dto.role.toString(),
          },
        },
      },
      select: {
        id: true,
        name: true,
        email: true,
        role: true,
        phone: true,
        createdAt: true,
      },
    });

    return user;
  }

  async getAllStaff() {
    return this.prisma.user.findMany({
      where: { role: { not: 'PATIENT' } },
      select: { id: true, name: true, email: true, role: true, phone: true, isActive: true, createdAt: true },
    });
  }
}
