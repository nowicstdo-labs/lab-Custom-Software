import { ExceptionFilter, Catch, ArgumentsHost, HttpException, HttpStatus, Logger } from '@nestjs/common';
import { Response, Request } from 'express';
import { Prisma } from '@prisma/client';

@Catch()
export class HttpExceptionFilter implements ExceptionFilter {
  private readonly logger = new Logger(HttpExceptionFilter.name);

  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const request = ctx.getRequest<Request>();

    let status = HttpStatus.INTERNAL_SERVER_ERROR;
    let errorMessage = 'Internal server error';

    if (exception instanceof HttpException) {
      status = exception.getStatus();
      const res = exception.getResponse();
      if (typeof res === 'object' && res !== null && 'message' in res) {
        const msg = (res as any).message;
        errorMessage = Array.isArray(msg) ? msg.join(', ') : String(msg);
      } else if (typeof res === 'string') {
        errorMessage = res;
      }

      if (status >= 500) {
        this.logger.error(`[${request.method} ${request.url}] ${status} - ${errorMessage}`, (exception as Error).stack);
      } else {
        this.logger.warn(`[${request.method} ${request.url}] ${status} - ${errorMessage}`);
      }
    } else if (exception instanceof Prisma.PrismaClientKnownRequestError) {
      // Prisma error mapping
      if (exception.code === 'P2002') {
        status = HttpStatus.CONFLICT;
        const targetStr = JSON.stringify(exception.meta?.target || '').toLowerCase();
        if (targetStr.includes('email')) {
          errorMessage = 'An account with this email address already exists. Please log in.';
        } else if (targetStr.includes('phone')) {
          errorMessage = 'An account with this mobile number already exists. Please log in.';
        } else if (targetStr.includes('patientid') || targetStr.includes('patient_id')) {
          errorMessage = 'Patient registration conflict. Please try submitting again.';
        } else {
          errorMessage = 'An account or record with this information already exists.';
        }
        this.logger.warn(`[PRISMA CONFLICT] ${request.method} ${request.url} - P2002 ${targetStr}`);
      } else if (exception.code === 'P2000') {
        status = HttpStatus.BAD_REQUEST;
        errorMessage = 'One of the provided values is too long.';
      } else if (exception.code === 'P2003') {
        status = HttpStatus.BAD_REQUEST;
        errorMessage = 'Referenced record was not found in database.';
      } else if (exception.code === 'P2025') {
        status = HttpStatus.NOT_FOUND;
        errorMessage = 'Requested record was not found.';
      } else {
        status = HttpStatus.BAD_REQUEST;
        errorMessage = `Database request error (${exception.code}). Please verify input parameters.`;
        this.logger.error(`[PRISMA ERROR ${exception.code}] ${request.method} ${request.url}`, exception.stack);
      }
    } else if (exception instanceof Prisma.PrismaClientInitializationError) {
      status = HttpStatus.SERVICE_UNAVAILABLE;
      errorMessage = 'Database connection error. Please verify database connectivity.';
      this.logger.error(`[PRISMA INIT ERROR] ${request.method} ${request.url}`, exception.stack);
    } else {
      // Unhandled generic internal server error
      const stack = exception instanceof Error ? exception.stack : String(exception);
      const message = exception instanceof Error ? exception.message : 'Unknown error';
      this.logger.error(`[UNHANDLED ERROR] ${request.method} ${request.url} - ${message}`, stack);
      status = HttpStatus.INTERNAL_SERVER_ERROR;
      errorMessage = 'Something went wrong on the server. Please try again later.';
    }

    response.status(status).json({
      success: false,
      message: errorMessage,
      code: status,
      timestamp: new Date().toISOString(),
    });
  }
}
