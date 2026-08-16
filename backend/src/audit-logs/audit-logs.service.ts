import { Injectable } from '@nestjs/common';
import { PrismaService } from '../database/prisma.service';

@Injectable()
export class AuditLogsService {
  constructor(private prisma: PrismaService) {}

  async createLog(userId: string | null, action: string, resourceType: string, resourceId?: string, details?: string, ipAddress?: string) {
    return this.prisma.auditLog.create({
      data: {
        userId,
        action,
        resourceType,
        resourceId,
        details,
        ipAddress,
      },
    });
  }

  async getAllLogs() {
    return this.prisma.auditLog.findMany({
      include: { user: { select: { name: true, email: true, role: true } } },
      orderBy: { createdAt: 'desc' },
      take: 100,
    });
  }
}
