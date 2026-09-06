-- CreateEnum
CREATE TYPE "Role" AS ENUM ('PATIENT', 'RECEPTIONIST', 'LAB_TECHNICIAN', 'DOCTOR', 'ADMIN');

-- CreateEnum
CREATE TYPE "BookingStatus" AS ENUM ('PENDING', 'CONFIRMED', 'CANCELLED', 'COMPLETED');

-- CreateEnum
CREATE TYPE "SampleStage" AS ENUM ('SAMPLE_COLLECTED', 'SAMPLE_RECEIVED', 'PROCESSING', 'TESTING', 'RESULT_ENTERED', 'COMPLETED');

-- CreateEnum
CREATE TYPE "ReportStage" AS ENUM ('DRAFT', 'TECHNICIAN_COMPLETED', 'PENDING_APPROVAL', 'APPROVED', 'REJECTED', 'FINAL');

-- CreateEnum
CREATE TYPE "Priority" AS ENUM ('ROUTINE', 'URGENT', 'STAT');

-- CreateEnum
CREATE TYPE "ResultFlag" AS ENUM ('NORMAL', 'HIGH', 'LOW');

-- CreateEnum
CREATE TYPE "PaymentStatus" AS ENUM ('PENDING', 'PAID', 'PARTIAL', 'REFUNDED');

-- CreateTable
CREATE TABLE "User" (
    "id" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "passwordHash" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "phone" TEXT,
    "role" "Role" NOT NULL DEFAULT 'PATIENT',
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PatientProfile" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "patientId" TEXT NOT NULL,
    "dob" TEXT,
    "gender" TEXT,
    "bloodGroup" TEXT,
    "address" TEXT,
    "alternateNumber" TEXT,
    "emergencyName" TEXT,
    "emergencyRelationship" TEXT,
    "emergencyPhone" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "PatientProfile_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "StaffProfile" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "employeeId" TEXT NOT NULL,
    "department" TEXT,
    "designation" TEXT,
    "joiningDate" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "StaffProfile_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "DoctorProfile" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "doctorId" TEXT NOT NULL,
    "specialization" TEXT NOT NULL,
    "qualification" TEXT NOT NULL,
    "experienceYears" INTEGER NOT NULL DEFAULT 0,
    "consultationFee" DOUBLE PRECISION NOT NULL DEFAULT 0.0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "DoctorProfile_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Test" (
    "id" TEXT NOT NULL,
    "testId" TEXT NOT NULL,
    "testName" TEXT NOT NULL,
    "category" TEXT NOT NULL,
    "price" DOUBLE PRECISION NOT NULL,
    "description" TEXT,
    "preparationInfo" TEXT,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Test_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "TestParameter" (
    "id" TEXT NOT NULL,
    "testId" TEXT NOT NULL,
    "parameterName" TEXT NOT NULL,
    "referenceRange" TEXT NOT NULL,
    "unit" TEXT NOT NULL,
    "minVal" DOUBLE PRECISION,
    "maxVal" DOUBLE PRECISION,
    "displayOrder" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "TestParameter_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AppointmentSlot" (
    "id" TEXT NOT NULL,
    "date" TEXT NOT NULL,
    "timeSlot" TEXT NOT NULL,
    "maxCapacity" INTEGER NOT NULL DEFAULT 10,
    "currentBookings" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "AppointmentSlot_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Booking" (
    "id" TEXT NOT NULL,
    "bookingId" TEXT NOT NULL,
    "patientId" TEXT NOT NULL,
    "testId" TEXT NOT NULL,
    "appointmentDate" TEXT NOT NULL,
    "timeSlot" TEXT NOT NULL,
    "price" DOUBLE PRECISION NOT NULL,
    "status" "BookingStatus" NOT NULL DEFAULT 'CONFIRMED',
    "paymentStatus" "PaymentStatus" NOT NULL DEFAULT 'PENDING',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Booking_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Appointment" (
    "id" TEXT NOT NULL,
    "appointmentId" TEXT NOT NULL,
    "patientId" TEXT NOT NULL,
    "doctorId" TEXT NOT NULL,
    "appointmentDate" TEXT NOT NULL,
    "timeSlot" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'Scheduled',
    "symptoms" TEXT,
    "diagnosis" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Appointment_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Sample" (
    "id" TEXT NOT NULL,
    "sampleId" TEXT NOT NULL,
    "bookingId" TEXT NOT NULL,
    "patientId" TEXT NOT NULL,
    "sampleType" TEXT NOT NULL,
    "barcodeToken" TEXT NOT NULL,
    "priority" "Priority" NOT NULL DEFAULT 'ROUTINE',
    "stage" "SampleStage" NOT NULL DEFAULT 'SAMPLE_COLLECTED',
    "collectionTime" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Sample_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "TestResult" (
    "id" TEXT NOT NULL,
    "sampleId" TEXT NOT NULL,
    "parameterId" TEXT NOT NULL,
    "resultValue" TEXT NOT NULL,
    "statusFlag" "ResultFlag" NOT NULL DEFAULT 'NORMAL',
    "evaluatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "TestResult_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "LabReport" (
    "id" TEXT NOT NULL,
    "reportId" TEXT NOT NULL,
    "bookingId" TEXT NOT NULL,
    "sampleId" TEXT NOT NULL,
    "patientId" TEXT NOT NULL,
    "doctorId" TEXT,
    "technicianId" TEXT,
    "stage" "ReportStage" NOT NULL DEFAULT 'DRAFT',
    "remarks" TEXT,
    "qrVerificationToken" TEXT NOT NULL,
    "finalizedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "LabReport_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ReportParameter" (
    "id" TEXT NOT NULL,
    "reportId" TEXT NOT NULL,
    "parameterName" TEXT NOT NULL,
    "resultValue" TEXT NOT NULL,
    "referenceRange" TEXT NOT NULL,
    "unit" TEXT NOT NULL,
    "statusFlag" "ResultFlag" NOT NULL DEFAULT 'NORMAL',

    CONSTRAINT "ReportParameter_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ReportApproval" (
    "id" TEXT NOT NULL,
    "reportId" TEXT NOT NULL,
    "reviewerId" TEXT NOT NULL,
    "status" "ReportStage" NOT NULL,
    "rejectionReason" TEXT,
    "reviewedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ReportApproval_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Formula" (
    "id" TEXT NOT NULL,
    "formulaId" TEXT NOT NULL,
    "formulaName" TEXT NOT NULL,
    "targetTestId" TEXT NOT NULL,
    "expression" TEXT NOT NULL,
    "parameters" TEXT NOT NULL,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Formula_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Invoice" (
    "id" TEXT NOT NULL,
    "invoiceNumber" TEXT NOT NULL,
    "bookingId" TEXT NOT NULL,
    "patientId" TEXT NOT NULL,
    "totalAmount" DOUBLE PRECISION NOT NULL,
    "discountAmount" DOUBLE PRECISION NOT NULL DEFAULT 0.0,
    "netAmount" DOUBLE PRECISION NOT NULL,
    "paymentStatus" "PaymentStatus" NOT NULL DEFAULT 'PENDING',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Invoice_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "InvoiceItem" (
    "id" TEXT NOT NULL,
    "invoiceId" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "amount" DOUBLE PRECISION NOT NULL,

    CONSTRAINT "InvoiceItem_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Payment" (
    "id" TEXT NOT NULL,
    "paymentId" TEXT NOT NULL,
    "invoiceId" TEXT NOT NULL,
    "amount" DOUBLE PRECISION NOT NULL,
    "paymentMethod" TEXT NOT NULL,
    "transactionReference" TEXT,
    "status" "PaymentStatus" NOT NULL DEFAULT 'PAID',
    "paidAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Payment_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Notification" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "message" TEXT NOT NULL,
    "isRead" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Notification_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AuditLog" (
    "id" TEXT NOT NULL,
    "userId" TEXT,
    "action" TEXT NOT NULL,
    "resourceType" TEXT NOT NULL,
    "resourceId" TEXT,
    "details" TEXT,
    "ipAddress" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "AuditLog_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "FileAttachment" (
    "id" TEXT NOT NULL,
    "resourceType" TEXT NOT NULL,
    "resourceId" TEXT NOT NULL,
    "fileName" TEXT NOT NULL,
    "fileUrl" TEXT NOT NULL,
    "mimeType" TEXT NOT NULL,
    "fileSize" INTEGER NOT NULL,
    "uploadedBy" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "FileAttachment_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "RefreshToken" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "tokenHash" TEXT NOT NULL,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "isRevoked" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "RefreshToken_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "OTPVerification" (
    "id" TEXT NOT NULL,
    "phoneOrEmail" TEXT NOT NULL,
    "otpHash" TEXT NOT NULL,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "isVerified" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "OTPVerification_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "User_email_key" ON "User"("email");

-- CreateIndex
CREATE INDEX "User_email_idx" ON "User"("email");

-- CreateIndex
CREATE INDEX "User_role_idx" ON "User"("role");

-- CreateIndex
CREATE UNIQUE INDEX "PatientProfile_userId_key" ON "PatientProfile"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "PatientProfile_patientId_key" ON "PatientProfile"("patientId");

-- CreateIndex
CREATE UNIQUE INDEX "StaffProfile_userId_key" ON "StaffProfile"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "StaffProfile_employeeId_key" ON "StaffProfile"("employeeId");

-- CreateIndex
CREATE UNIQUE INDEX "DoctorProfile_userId_key" ON "DoctorProfile"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "DoctorProfile_doctorId_key" ON "DoctorProfile"("doctorId");

-- CreateIndex
CREATE UNIQUE INDEX "Test_testId_key" ON "Test"("testId");

-- CreateIndex
CREATE UNIQUE INDEX "AppointmentSlot_date_timeSlot_key" ON "AppointmentSlot"("date", "timeSlot");

-- CreateIndex
CREATE UNIQUE INDEX "Booking_bookingId_key" ON "Booking"("bookingId");

-- CreateIndex
CREATE UNIQUE INDEX "Appointment_appointmentId_key" ON "Appointment"("appointmentId");

-- CreateIndex
CREATE UNIQUE INDEX "Sample_sampleId_key" ON "Sample"("sampleId");

-- CreateIndex
CREATE UNIQUE INDEX "Sample_barcodeToken_key" ON "Sample"("barcodeToken");

-- CreateIndex
CREATE UNIQUE INDEX "LabReport_reportId_key" ON "LabReport"("reportId");

-- CreateIndex
CREATE UNIQUE INDEX "LabReport_bookingId_key" ON "LabReport"("bookingId");

-- CreateIndex
CREATE UNIQUE INDEX "LabReport_qrVerificationToken_key" ON "LabReport"("qrVerificationToken");

-- CreateIndex
CREATE UNIQUE INDEX "Formula_formulaId_key" ON "Formula"("formulaId");

-- CreateIndex
CREATE UNIQUE INDEX "Invoice_invoiceNumber_key" ON "Invoice"("invoiceNumber");

-- CreateIndex
CREATE UNIQUE INDEX "Invoice_bookingId_key" ON "Invoice"("bookingId");

-- CreateIndex
CREATE UNIQUE INDEX "Payment_paymentId_key" ON "Payment"("paymentId");

-- CreateIndex
CREATE UNIQUE INDEX "RefreshToken_tokenHash_key" ON "RefreshToken"("tokenHash");

-- AddForeignKey
ALTER TABLE "PatientProfile" ADD CONSTRAINT "PatientProfile_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "StaffProfile" ADD CONSTRAINT "StaffProfile_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "DoctorProfile" ADD CONSTRAINT "DoctorProfile_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TestParameter" ADD CONSTRAINT "TestParameter_testId_fkey" FOREIGN KEY ("testId") REFERENCES "Test"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Booking" ADD CONSTRAINT "Booking_patientId_fkey" FOREIGN KEY ("patientId") REFERENCES "PatientProfile"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Booking" ADD CONSTRAINT "Booking_testId_fkey" FOREIGN KEY ("testId") REFERENCES "Test"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Appointment" ADD CONSTRAINT "Appointment_patientId_fkey" FOREIGN KEY ("patientId") REFERENCES "PatientProfile"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Appointment" ADD CONSTRAINT "Appointment_doctorId_fkey" FOREIGN KEY ("doctorId") REFERENCES "DoctorProfile"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Sample" ADD CONSTRAINT "Sample_bookingId_fkey" FOREIGN KEY ("bookingId") REFERENCES "Booking"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Sample" ADD CONSTRAINT "Sample_patientId_fkey" FOREIGN KEY ("patientId") REFERENCES "PatientProfile"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TestResult" ADD CONSTRAINT "TestResult_sampleId_fkey" FOREIGN KEY ("sampleId") REFERENCES "Sample"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TestResult" ADD CONSTRAINT "TestResult_parameterId_fkey" FOREIGN KEY ("parameterId") REFERENCES "TestParameter"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "LabReport" ADD CONSTRAINT "LabReport_bookingId_fkey" FOREIGN KEY ("bookingId") REFERENCES "Booking"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "LabReport" ADD CONSTRAINT "LabReport_sampleId_fkey" FOREIGN KEY ("sampleId") REFERENCES "Sample"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "LabReport" ADD CONSTRAINT "LabReport_patientId_fkey" FOREIGN KEY ("patientId") REFERENCES "PatientProfile"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "LabReport" ADD CONSTRAINT "LabReport_doctorId_fkey" FOREIGN KEY ("doctorId") REFERENCES "DoctorProfile"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ReportParameter" ADD CONSTRAINT "ReportParameter_reportId_fkey" FOREIGN KEY ("reportId") REFERENCES "LabReport"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ReportApproval" ADD CONSTRAINT "ReportApproval_reportId_fkey" FOREIGN KEY ("reportId") REFERENCES "LabReport"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Formula" ADD CONSTRAINT "Formula_targetTestId_fkey" FOREIGN KEY ("targetTestId") REFERENCES "Test"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Invoice" ADD CONSTRAINT "Invoice_bookingId_fkey" FOREIGN KEY ("bookingId") REFERENCES "Booking"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Invoice" ADD CONSTRAINT "Invoice_patientId_fkey" FOREIGN KEY ("patientId") REFERENCES "PatientProfile"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "InvoiceItem" ADD CONSTRAINT "InvoiceItem_invoiceId_fkey" FOREIGN KEY ("invoiceId") REFERENCES "Invoice"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Payment" ADD CONSTRAINT "Payment_invoiceId_fkey" FOREIGN KEY ("invoiceId") REFERENCES "Invoice"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Notification" ADD CONSTRAINT "Notification_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AuditLog" ADD CONSTRAINT "AuditLog_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RefreshToken" ADD CONSTRAINT "RefreshToken_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

