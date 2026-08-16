import { Controller, Get, Patch, Body, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { AdminService } from './admin.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { RolesGuard } from '../common/guards/roles.guard';
import { Roles } from '../common/decorators/roles.decorator';
import { Role } from '@prisma/client';

@ApiTags('Admin Operations & Dynamic CMS Control')
@Controller('api/v1/admin')
export class AdminController {
  constructor(private adminService: AdminService) {}

  @Get('stats')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(Role.ADMIN)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get live system metrics, revenue, and operation stats' })
  getDashboardStats() {
    return this.adminService.getDashboardStats();
  }

  @Get('cms/home')
  @ApiOperation({ summary: 'Get Home screen CMS configuration' })
  getHomeCms() {
    return this.adminService.getHomeCms();
  }

  @Patch('cms/home')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(Role.ADMIN)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Update Home screen CMS configuration' })
  updateHomeCms(@Body() body: any) {
    return this.adminService.updateHomeCms(body);
  }

  @Get('cms/lab-profile')
  @ApiOperation({ summary: 'Get Lab profile and report header/footer branding' })
  getLabProfileCms() {
    return this.adminService.getLabProfileCms();
  }

  @Patch('cms/lab-profile')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(Role.ADMIN)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Update Lab profile branding' })
  updateLabProfileCms(@Body() body: any) {
    return this.adminService.updateLabProfileCms(body);
  }

  @Get('cms/features')
  @ApiOperation({ summary: 'Get application feature control switches' })
  getFeatureSwitches() {
    return this.adminService.getFeatureSwitches();
  }

  @Patch('cms/features')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(Role.ADMIN)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Update application feature control switches' })
  updateFeatureSwitches(@Body() body: any) {
    return this.adminService.updateFeatureSwitches(body);
  }
}
