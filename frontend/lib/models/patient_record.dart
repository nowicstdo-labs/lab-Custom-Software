class PatientTimelineEntry {
  final String title;
  final String description;
  final DateTime timestamp;

  const PatientTimelineEntry({
    required this.title,
    required this.description,
    required this.timestamp,
  });
}

class PatientRecord {
  final String patientId;
  final DateTime registrationDate;
  final String fullName;
  final String gender;
  final DateTime dateOfBirth;
  final int age;
  final String bloodGroup;
  final String mobileNumber;
  final String? alternateNumber;
  final String? email;
  final String address;
  final String? emergencyContact;
  final String medicalHistory;
  final String allergies;
  final String currentMedications;
  final String? referringDoctor;
  final String? aadhaarNumber;
  final List<PatientTimelineEntry> timeline;
  final List<String> previousAppointments;
  final List<String> previousReports;
  final List<String> previousPrescriptions;
  final List<String> previousPayments;

  const PatientRecord({
    required this.patientId,
    required this.registrationDate,
    required this.fullName,
    required this.gender,
    required this.dateOfBirth,
    required this.age,
    required this.bloodGroup,
    required this.mobileNumber,
    this.alternateNumber,
    this.email,
    required this.address,
    this.emergencyContact,
    required this.medicalHistory,
    required this.allergies,
    required this.currentMedications,
    this.referringDoctor,
    this.aadhaarNumber,
    required this.timeline,
    required this.previousAppointments,
    required this.previousReports,
    required this.previousPrescriptions,
    required this.previousPayments,
  });

  PatientRecord copyWith({
    String? patientId,
    DateTime? registrationDate,
    String? fullName,
    String? gender,
    DateTime? dateOfBirth,
    int? age,
    String? bloodGroup,
    String? mobileNumber,
    String? alternateNumber,
    String? email,
    String? address,
    String? emergencyContact,
    String? medicalHistory,
    String? allergies,
    String? currentMedications,
    String? referringDoctor,
    String? aadhaarNumber,
    List<PatientTimelineEntry>? timeline,
    List<String>? previousAppointments,
    List<String>? previousReports,
    List<String>? previousPrescriptions,
    List<String>? previousPayments,
  }) {
    return PatientRecord(
      patientId: patientId ?? this.patientId,
      registrationDate: registrationDate ?? this.registrationDate,
      fullName: fullName ?? this.fullName,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      age: age ?? this.age,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      alternateNumber: alternateNumber ?? this.alternateNumber,
      email: email ?? this.email,
      address: address ?? this.address,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      allergies: allergies ?? this.allergies,
      currentMedications: currentMedications ?? this.currentMedications,
      referringDoctor: referringDoctor ?? this.referringDoctor,
      aadhaarNumber: aadhaarNumber ?? this.aadhaarNumber,
      timeline: timeline ?? this.timeline,
      previousAppointments: previousAppointments ?? this.previousAppointments,
      previousReports: previousReports ?? this.previousReports,
      previousPrescriptions: previousPrescriptions ?? this.previousPrescriptions,
      previousPayments: previousPayments ?? this.previousPayments,
    );
  }
}
