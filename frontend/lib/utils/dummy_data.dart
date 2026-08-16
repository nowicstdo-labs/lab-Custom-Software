import '../features/auth/auth_models.dart';
import '../models/appointment.dart';
import '../models/doctor.dart';
import '../models/health_package.dart';
import '../models/lab_test.dart';
import '../models/notification_item.dart';

final demoHealthPackages = [
  const HealthPackage(
    id: 'p1',
    name: 'Executive Health Package',
    category: 'Premium',
    description: 'Complete health screening for executive wellness.',
    price: 2499.00,
    includes: ['Blood Panel', 'Cardiac Check', 'Liver Profile', 'Diabetic Panel'],
  ),
  const HealthPackage(
    id: 'p2',
    name: 'Family Care Package',
    category: 'Family',
    description: 'Designed for modern families with preventive care tests.',
    price: 1799.00,
    includes: ['CBC', 'Thyroid Panel', 'Vitamin D', 'Urine Analysis'],
  ),
];

final demoLabTests = [
  const LabTest(
    id: 't1',
    name: 'CBC (Complete Blood Count)',
    category: 'Blood Tests',
    description: 'Measures different components of blood.',
    sampleType: 'Blood',
    turnaround: 'Same Day',
    preparation: 'Fasting not required.',
    price: 399.00,
  ),
  const LabTest(
    id: 't2',
    name: 'Liver Function Test (LFT)',
    category: 'Biochemistry',
    description: 'Evaluates the health of your liver.',
    sampleType: 'Blood',
    turnaround: '24 Hrs',
    preparation: '10-12 hrs fasting required.',
    price: 699.00,
  ),
  const LabTest(
    id: 't3',
    name: 'Kidney Function Test (KFT)',
    category: 'Biochemistry',
    description: 'Measures kidney function and performance.',
    sampleType: 'Blood',
    turnaround: '24 Hrs',
    preparation: 'Fasting optional.',
    price: 599.00,
  ),
  const LabTest(
    id: 't4',
    name: 'Lipid Profile',
    category: 'Blood Tests',
    description: 'Measures cholesterol and triglyceride levels.',
    sampleType: 'Blood',
    turnaround: '24 Hrs',
    preparation: '12 hrs fasting required.',
    price: 699.00,
  ),
  const LabTest(
    id: 't5',
    name: 'Thyroid Profile (T3, T4, TSH)',
    category: 'Hormones',
    description: 'Evaluates thyroid gland function.',
    sampleType: 'Blood',
    turnaround: '24 Hrs',
    preparation: 'Morning sample preferred.',
    price: 499.00,
  ),
  const LabTest(
    id: 't6',
    name: 'Urine Routine Analysis',
    category: 'Urine',
    description: 'Screening test to check for metabolic and kidney disorders.',
    sampleType: 'Urine',
    turnaround: 'Same Day',
    preparation: 'First morning urine sample.',
    price: 299.00,
  ),
];

final List<Appointment> demoAppointments = const [];

final demoNotifications = [
  const NotificationItem(
    id: 'n1',
    title: 'Report Ready',
    message: 'Your lab report for CBC is available to download.',
    timestamp: '2 hours ago',
    unread: true,
  ),
  const NotificationItem(
    id: 'n2',
    title: 'Appointment Reminder',
    message: 'Tomorrow at 10:30 AM with Dr. John Smith.',
    timestamp: '5 hours ago',
  ),
];

final demoUsers = [
  const {'email': 'patient@astha.com', 'role': UserRole.patient},
  const {'email': 'reception@astha.com', 'role': UserRole.receptionist},
  const {'email': 'lab@astha.com', 'role': UserRole.labTechnician},
  const {'email': 'doctor@astha.com', 'role': UserRole.doctor},
];

// ---------------------------------------------------------------------------
// Mock Doctors (Matching Reference Image)
// ---------------------------------------------------------------------------

final mockDoctors = [
  const Doctor(
    id: 'd1',
    name: 'Dr. John Smith',
    qualification: 'MBBS, MD (Cardiology)',
    specialization: 'Cardiologist',
    experience: '10 Years Experience',
    availability: 'Available Today',
    consultationFee: '₹ 500',
    about: 'Dr. John Smith is a senior cardiologist with expertise in interventional cardiology, heart failure management, and preventive cardiac care.',
    localImagePath: 'assets/images/doctor_male_1.png',
    rating: 4.8,
    patientsServed: 5200,
  ),
  const Doctor(
    id: 'd2',
    name: 'Dr. Aisha Sharma',
    qualification: 'MBBS, MD (Medicine)',
    specialization: 'General Physician',
    experience: '8 Years Experience',
    availability: 'Available Tomorrow',
    consultationFee: '₹ 400',
    about: 'Dr. Aisha Sharma specializes in internal medicine, lifestyle diseases, and general health checkups.',
    localImagePath: 'assets/images/doctor_female_1.png',
    rating: 4.7,
    patientsServed: 3800,
  ),
  const Doctor(
    id: 'd3',
    name: 'Dr. Michael Brown',
    qualification: 'MBBS, DM (Neurology)',
    specialization: 'Neurologist',
    experience: '12 Years Experience',
    availability: 'Available Today',
    consultationFee: '₹ 700',
    about: 'Dr. Michael Brown is an expert neurologist specializing in brain disorders, stroke management, and nerve health.',
    localImagePath: 'assets/images/doctor_male_2.png',
    rating: 4.9,
    patientsServed: 4600,
  ),
  const Doctor(
    id: 'd4',
    name: 'Dr. Sophia Williams',
    qualification: 'MBBS, MD (Dermatology)',
    specialization: 'Dermatologist',
    experience: '9 Years Experience',
    availability: 'Available Today',
    consultationFee: '₹ 600',
    about: 'Dr. Sophia Williams is a renowned dermatologist offering treatments for skin, hair, and nail conditions.',
    localImagePath: 'assets/images/doctor_female_2.png',
    rating: 4.6,
    patientsServed: 8500,
  ),
];

// ---------------------------------------------------------------------------
// Mock Appointment Slots (with capacity counters)
// ---------------------------------------------------------------------------

/// A single bookable time slot.
/// [bookedCount] is mocked for the frontend. Backend must enforce max = [maxCapacity].
class AppointmentSlot {
  final String time;
  final int bookedCount;
  final int maxCapacity;

  const AppointmentSlot({
    required this.time,
    required this.bookedCount,
    this.maxCapacity = 10,
  });

  bool get isFull => bookedCount >= maxCapacity;
  bool get isAlmostFull => !isFull && bookedCount >= maxCapacity - 2;
  int get remaining => maxCapacity - bookedCount;
}

/// Mock slot data demonstrating all possible states.
final mockAppointmentSlots = [
  const AppointmentSlot(time: '09:00 AM', bookedCount: 0),
  const AppointmentSlot(time: '09:30 AM', bookedCount: 3),
  const AppointmentSlot(time: '10:00 AM', bookedCount: 7),
  const AppointmentSlot(time: '10:30 AM', bookedCount: 8),
  const AppointmentSlot(time: '11:00 AM', bookedCount: 9),
  const AppointmentSlot(time: '11:30 AM', bookedCount: 10),
  const AppointmentSlot(time: '12:00 PM', bookedCount: 5),
  const AppointmentSlot(time: '12:30 PM', bookedCount: 10),
  const AppointmentSlot(time: '02:00 PM', bookedCount: 2),
  const AppointmentSlot(time: '02:30 PM', bookedCount: 6),
  const AppointmentSlot(time: '03:00 PM', bookedCount: 10),
  const AppointmentSlot(time: '03:30 PM', bookedCount: 4),
  const AppointmentSlot(time: '04:00 PM', bookedCount: 9),
  const AppointmentSlot(time: '04:30 PM', bookedCount: 1),
];
