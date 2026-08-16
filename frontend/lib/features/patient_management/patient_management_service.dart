import '../../models/patient_record.dart';

class PatientRegistrationResult {
  final PatientRecord patient;
  final bool created;
  final bool duplicateFound;
  final String message;

  const PatientRegistrationResult({
    required this.patient,
    required this.created,
    required this.duplicateFound,
    required this.message,
  });
}

class PatientManagementService {
  final List<PatientRecord> _patients = [];
  int _nextSequence = 3;

  PatientManagementService() {
    _patients.addAll(_seedPatients());
    _nextSequence = _patients.length + 1;
  }

  List<PatientRecord> get patients => List.unmodifiable(_patients);

  List<PatientRecord> searchPatients(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return const [];
    }

    return _patients.where((patient) {
      return patient.patientId.toLowerCase().contains(normalized) ||
          patient.fullName.toLowerCase().contains(normalized) ||
          patient.mobileNumber.contains(normalized) ||
          (patient.aadhaarNumber?.toLowerCase().contains(normalized) ?? false);
    }).toList();
  }

  PatientRegistrationResult registerPatient({
    required String fullName,
    required String gender,
    required DateTime dateOfBirth,
    required String bloodGroup,
    required String mobileNumber,
    String? alternateNumber,
    String? email,
    required String address,
    String? emergencyContact,
    String? medicalHistory,
    String? allergies,
    String? currentMedications,
    String? referringDoctor,
    String? aadhaarNumber,
  }) {
    final duplicate = _findDuplicate(mobileNumber: mobileNumber, aadhaarNumber: aadhaarNumber);
    if (duplicate != null) {
      return PatientRegistrationResult(
        patient: duplicate,
        created: false,
        duplicateFound: true,
        message: 'Existing patient found. Duplicate patient creation prevented.',
      );
    }

    final newPatient = PatientRecord(
      patientId: _generatePatientId(),
      registrationDate: DateTime.now(),
      fullName: fullName,
      gender: gender,
      dateOfBirth: dateOfBirth,
      age: _calculateAge(dateOfBirth),
      bloodGroup: bloodGroup,
      mobileNumber: mobileNumber,
      alternateNumber: alternateNumber,
      email: email,
      address: address,
      emergencyContact: emergencyContact,
      medicalHistory: medicalHistory ?? 'No major conditions noted.',
      allergies: allergies ?? 'None reported.',
      currentMedications: currentMedications ?? 'None',
      referringDoctor: referringDoctor,
      aadhaarNumber: aadhaarNumber,
      timeline: [
        PatientTimelineEntry(
          title: 'Registration',
          description: 'Patient registered with Astha Diagnostic.',
          timestamp: DateTime.now(),
        ),
      ],
      previousAppointments: ['CBC test booked - 09 Aug 2026', 'Doctor consultation - 12 Aug 2026'],
      previousReports: ['CBC report ready', 'Lipid profile report ready'],
      previousPrescriptions: ['Vitamin D3', 'Omeprazole'],
      previousPayments: ['₹1,200 - 09 Aug 2026', '₹900 - 12 Aug 2026'],
    );

    _patients.add(newPatient);
    _nextSequence += 1;
    return PatientRegistrationResult(
      patient: newPatient,
      created: true,
      duplicateFound: false,
      message: 'Patient registered successfully with ID ${newPatient.patientId}.',
    );
  }

  PatientRecord? _findDuplicate({required String mobileNumber, String? aadhaarNumber}) {
    for (final patient in _patients) {
      final sameMobile = patient.mobileNumber == mobileNumber;
      final sameAadhaar = aadhaarNumber != null && patient.aadhaarNumber != null && patient.aadhaarNumber == aadhaarNumber;
      if (sameMobile || sameAadhaar) {
        return patient;
      }
    }
    return null;
  }

  String _generatePatientId() {
    final year = DateTime.now().year;
    return 'AD-$year-${_nextSequence.toString().padLeft(6, '0')}';
  }

  int _calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month || (today.month == birthDate.month && today.day < birthDate.day)) {
      age -= 1;
    }
    return age;
  }

  List<PatientRecord> _seedPatients() {
    return [
      PatientRecord(
        patientId: 'AD-2026-000001',
        registrationDate: DateTime(2026, 2, 2),
        fullName: 'Nidhi Sharma',
        gender: 'Female',
        dateOfBirth: DateTime(1992, 4, 11),
        age: 34,
        bloodGroup: 'B+',
        mobileNumber: '+919876543210',
        alternateNumber: '+919811223344',
        email: 'nidhi@astha.com',
        address: '12, Green Park, Bengaluru',
        emergencyContact: '+918888777666',
        medicalHistory: 'History of migraine and vitamin D deficiency.',
        allergies: 'Penicillin',
        currentMedications: 'Paracetamol, Vitamin D 3',
        referringDoctor: 'Dr. Asha Rao',
        aadhaarNumber: '1234-5678-9012',
        timeline: [
          PatientTimelineEntry(title: 'Registration', description: 'Registered for annual health panel.', timestamp: DateTime(2026, 2, 2)),
          PatientTimelineEntry(title: 'Test Booking', description: 'CBC and thyroid panel booked.', timestamp: DateTime(2026, 2, 5)),
          PatientTimelineEntry(title: 'Reports Generated', description: 'CBC report was generated.', timestamp: DateTime(2026, 2, 7)),
          PatientTimelineEntry(title: 'Payment', description: 'Payment received for diagnostics.', timestamp: DateTime(2026, 2, 7)),
        ],
        previousAppointments: ['CBC test booked - 05 Feb 2026', 'Follow-up consult - 12 Feb 2026'],
        previousReports: ['CBC report ready', 'Thyroid panel report ready'],
        previousPrescriptions: ['Vitamin D3', 'Sumatriptan'],
        previousPayments: ['₹1,200 - 05 Feb 2026', '₹850 - 12 Feb 2026'],
      ),
      PatientRecord(
        patientId: 'AD-2026-000002',
        registrationDate: DateTime(2026, 5, 12),
        fullName: 'Rohit Verma',
        gender: 'Male',
        dateOfBirth: DateTime(1988, 9, 19),
        age: 38,
        bloodGroup: 'O+',
        mobileNumber: '+919812345678',
        alternateNumber: '+919833445566',
        email: 'rohit@astha.com',
        address: '56, Lotus Avenue, Pune',
        emergencyContact: '+919100200300',
        medicalHistory: 'Diabetes under control with diet and medication.',
        allergies: 'None',
        currentMedications: 'Metformin',
        referringDoctor: 'Dr. Neeraj Malhotra',
        aadhaarNumber: '3456-7890-1234',
        timeline: [
          PatientTimelineEntry(title: 'Registration', description: 'Registered for diabetes follow-up.', timestamp: DateTime(2026, 5, 12)),
          PatientTimelineEntry(title: 'Sample Collection', description: 'Blood sample collected.', timestamp: DateTime(2026, 5, 13)),
          PatientTimelineEntry(title: 'Doctor Consultation', description: 'Consultation completed with medication review.', timestamp: DateTime(2026, 5, 15)),
        ],
        previousAppointments: ['Diabetes profile - 13 May 2026', 'Cardio consult - 15 May 2026'],
        previousReports: ['HbA1c report ready', 'Lipid profile report ready'],
        previousPrescriptions: ['Metformin', 'Aspirin'],
        previousPayments: ['₹1,500 - 13 May 2026'],
      ),
    ];
  }
}
