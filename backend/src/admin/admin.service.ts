import { Injectable } from '@nestjs/common';
import { PrismaService } from '../database/prisma.service';

@Injectable()
export class AdminService {
  constructor(private prisma: PrismaService) {}

  private cmsConfig = {
    home: {
      heroTitle: 'Your Health, Our Priority',
      heroSubtitle: 'Accurate diagnostics with trusted care across modern operations.',
      heroButtonText: 'Book a Test',
      bannerImageUrl: null,
      promoTitle: 'Full Body Checkup Package @ 40% OFF',
      showPromoBanner: true,
    },
    labProfile: {
      labName: 'Astha Diagnostic Laboratory',
      phone: '+91 98765 43210',
      email: 'contact@asthadiagnostic.com',
      address: '102 Healthcare Avenue, Medical District, City - 380001',
      headerText: 'ASTHA DIAGNOSTIC LABORATORY — ISO 9001:2015 CERTIFIED',
      footerText: 'This is an electronically verified digital diagnostic report.',
      logoUrl: null,
    },
    features: {
      patientRegistration: true,
      testBooking: true,
      doctorConsultation: true,
      onlineReports: true,
      homeCollection: true,
    },
  };

  async getDashboardStats() {
    const [totalPatients, totalBookings, totalStaff, totalReports, invoices] = await Promise.all([
      this.prisma.patientProfile.count(),
      this.prisma.booking.count(),
      this.prisma.staffProfile.count(),
      this.prisma.labReport.count(),
      this.prisma.invoice.findMany({ select: { totalAmount: true, paymentStatus: true } }),
    ]);

    const totalRevenue = invoices.reduce((sum, inv) => sum + (inv.totalAmount || 0), 0);
    const pendingRevenue = invoices
      .filter((inv) => inv.paymentStatus === 'PENDING')
      .reduce((sum, inv) => sum + (inv.totalAmount || 0), 0);

    return {
      totalPatients,
      totalBookings,
      totalStaff,
      totalReports,
      totalRevenue,
      pendingRevenue,
    };
  }

  async getHomeCms() {
    return this.cmsConfig.home;
  }

  async updateHomeCms(data: any) {
    this.cmsConfig.home = { ...this.cmsConfig.home, ...data };
    return this.cmsConfig.home;
  }

  async getLabProfileCms() {
    return this.cmsConfig.labProfile;
  }

  async updateLabProfileCms(data: any) {
    this.cmsConfig.labProfile = { ...this.cmsConfig.labProfile, ...data };
    return this.cmsConfig.labProfile;
  }

  async getFeatureSwitches() {
    return this.cmsConfig.features;
  }

  async updateFeatureSwitches(data: any) {
    this.cmsConfig.features = { ...this.cmsConfig.features, ...data };
    return this.cmsConfig.features;
  }
}
