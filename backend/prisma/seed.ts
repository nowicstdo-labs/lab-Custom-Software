import { PrismaClient, Role, Priority, SampleStage, BookingStatus, PaymentStatus } from '@prisma/client';
import * as argon2 from 'argon2';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Starting Astha Diagnostic Database Seed...');

  const defaultPass = await argon2.hash('password');
  const adminPass = await argon2.hash('Admin@123');

  // 1. Seed Users & Profiles for all 5 roles
  const adminUser = await prisma.user.upsert({
    where: { email: 'admin@asthadiagnostic.com' },
    update: {},
    create: {
      email: 'admin@asthadiagnostic.com',
      passwordHash: adminPass,
      name: 'Dr. Astha Verma',
      role: Role.ADMIN,
      phone: '+919800000001',
    },
  });

  const doctorUser = await prisma.user.upsert({
    where: { email: 'doctor@astha.com' },
    update: {},
    create: {
      email: 'doctor@astha.com',
      passwordHash: defaultPass,
      name: 'Dr. Priya Mehta',
      role: Role.DOCTOR,
      phone: '+919800000002',
      doctorProfile: {
        create: {
          doctorId: 'DOC-001',
          specialization: 'Pathology',
          qualification: 'MD Pathology',
          experienceYears: 12,
          consultationFee: 800.0,
        },
      },
    },
  });

  const labTechUser = await prisma.user.upsert({
    where: { email: 'labtech@astha.com' },
    update: {},
    create: {
      email: 'labtech@astha.com',
      passwordHash: defaultPass,
      name: 'Rohit Sharma',
      role: Role.LAB_TECHNICIAN,
      phone: '+919800000003',
      staffProfile: {
        create: {
          employeeId: 'EMP-LT-01',
          department: 'Hematology',
          designation: 'Senior Lab Technician',
        },
      },
    },
  });

  const receptionistUser = await prisma.user.upsert({
    where: { email: 'receptionist@astha.com' },
    update: {},
    create: {
      email: 'receptionist@astha.com',
      passwordHash: defaultPass,
      name: 'Anita Sharma',
      role: Role.RECEPTIONIST,
      phone: '+919800000004',
      staffProfile: {
        create: {
          employeeId: 'EMP-REC-01',
          department: 'Front Desk',
          designation: 'Reception Officer',
        },
      },
    },
  });

  const patientUser = await prisma.user.upsert({
    where: { email: 'patient@astha.com' },
    update: {},
    create: {
      email: 'patient@astha.com',
      passwordHash: defaultPass,
      name: 'Rahul Kumar',
      role: Role.PATIENT,
      phone: '+919876543210',
      patientProfile: {
        create: {
          patientId: 'ASTH-P-000125',
          dob: '12-05-1997',
          gender: 'Male',
          bloodGroup: 'O+',
          address: '742 Evergreen Terrace, Sector 14, New Delhi',
        },
      },
    },
  });

  console.log('✅ 5 Demo Users Seeded Successfully');

  // 2. Seed Diagnostic Tests & Parameters
  const cbcTest = await prisma.test.upsert({
    where: { testId: 'TEST-CBC' },
    update: {},
    create: {
      testId: 'TEST-CBC',
      testName: 'Complete Blood Count (CBC)',
      category: 'Hematology',
      price: 450.0,
      description: 'Comprehensive evaluation of RBC, WBC, Hemoglobin, and Platelets',
      preparationInfo: 'No special fasting required',
      parameters: {
        create: [
          { parameterName: 'Hemoglobin (Hb)', referenceRange: '13.0 - 17.0', unit: 'g/dL', minVal: 13.0, maxVal: 17.0, displayOrder: 1 },
          { parameterName: 'Total RBC Count', referenceRange: '4.5 - 5.5', unit: 'mill/cumm', minVal: 4.5, maxVal: 5.5, displayOrder: 2 },
          { parameterName: 'Total WBC Count', referenceRange: '4000 - 11000', unit: '/cumm', minVal: 4000, maxVal: 11000, displayOrder: 3 },
          { parameterName: 'Platelet Count', referenceRange: '150000 - 450000', unit: '/cumm', minVal: 150000, maxVal: 450000, displayOrder: 4 },
        ],
      },
    },
  });

  await prisma.test.upsert({
    where: { testId: 'TEST-LIPID' },
    update: {},
    create: {
      testId: 'TEST-LIPID',
      testName: 'Lipid Profile',
      category: 'Biochemistry',
      price: 850.0,
      description: 'Evaluation of Total Cholesterol, HDL, LDL, and Triglycerides',
      preparationInfo: '10-12 hours overnight fasting mandatory',
    },
  });

  console.log('✅ Diagnostic Tests & Parameters Seeded');

  // 3. Seed Medical Formulas
  await prisma.formula.upsert({
    where: { formulaId: 'FRM-001' },
    update: {},
    create: {
      formulaId: 'FRM-001',
      formulaName: 'Indirect Bilirubin',
      targetTestId: cbcTest.id,
      expression: 'TOTAL_BIL - DIRECT_BIL',
      parameters: 'TOTAL_BIL,DIRECT_BIL',
    },
  });

  await prisma.formula.upsert({
    where: { formulaId: 'FRM-002' },
    update: {},
    create: {
      formulaId: 'FRM-002',
      formulaName: 'Globulin Calculation',
      targetTestId: cbcTest.id,
      expression: 'TOTAL_PROTEIN - ALBUMIN',
      parameters: 'TOTAL_PROTEIN,ALBUMIN',
    },
  });

  // 4. Seed Time Slots with Max 10 Capacity
  const today = '14-08-2026';
  const slots = ['09:00 AM', '09:30 AM', '10:00 AM', '10:30 AM', '11:00 AM', '11:30 AM'];
  for (const slot of slots) {
    await prisma.appointmentSlot.upsert({
      where: { date_timeSlot: { date: today, timeSlot: slot } },
      update: {},
      create: {
        date: today,
        timeSlot: slot,
        maxCapacity: 10,
        currentBookings: slot === '11:00 AM' ? 10 : (slot === '10:30 AM' ? 8 : 3),
      },
    });
  }

  console.log('✅ Time Slots (Max 10 Capacity) Seeded');
  console.log('🎉 Seed Execution Completed Successfully!');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
