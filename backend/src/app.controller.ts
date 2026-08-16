import { Controller, Get } from '@nestjs/common';

@Controller()
export class AppController {
  @Get('health')
  healthCheck() {
    return {
      status: 'ok',
      service: 'Astha Diagnostic Backend API',
      timestamp: new Date().toISOString(),
    };
  }
}
