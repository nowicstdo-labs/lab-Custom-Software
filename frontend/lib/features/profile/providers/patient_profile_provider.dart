import 'package:flutter_riverpod/flutter_riverpod.dart';

class PatientProfileData {
  final String fullName;
  final String patientId;
  final bool isVerified;
  final String dob;
  final String gender;
  final String bloodGroup;
  final String phone;
  final String email;
  final String alternateNumber;
  final String address;
  final String emergencyName;
  final String emergencyRelationship;
  final String emergencyPhone;
  final String height;
  final String weight;
  final String bmi;
  final String bmiStatus;
  final String lastCheckup;
  final String allergies;

  const PatientProfileData({
    required this.fullName,
    required this.patientId,
    this.isVerified = true,
    required this.dob,
    required this.gender,
    required this.bloodGroup,
    required this.phone,
    required this.email,
    required this.alternateNumber,
    required this.address,
    required this.emergencyName,
    required this.emergencyRelationship,
    required this.emergencyPhone,
    required this.height,
    required this.weight,
    required this.bmi,
    required this.bmiStatus,
    required this.lastCheckup,
    required this.allergies,
  });

  PatientProfileData copyWith({
    String? fullName,
    String? dob,
    String? gender,
    String? bloodGroup,
    String? phone,
    String? email,
    String? alternateNumber,
    String? address,
    String? emergencyName,
    String? emergencyRelationship,
    String? emergencyPhone,
  }) {
    return PatientProfileData(
      fullName: fullName ?? this.fullName,
      patientId: patientId,
      isVerified: isVerified,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      alternateNumber: alternateNumber ?? this.alternateNumber,
      address: address ?? this.address,
      emergencyName: emergencyName ?? this.emergencyName,
      emergencyRelationship: emergencyRelationship ?? this.emergencyRelationship,
      emergencyPhone: emergencyPhone ?? this.emergencyPhone,
      height: height,
      weight: weight,
      bmi: bmi,
      bmiStatus: bmiStatus,
      lastCheckup: lastCheckup,
      allergies: allergies,
    );
  }
}

final patientProfileProvider =
    StateNotifierProvider<PatientProfileNotifier, PatientProfileData>((ref) {
  return PatientProfileNotifier();
});

class PatientProfileNotifier extends StateNotifier<PatientProfileData> {
  PatientProfileNotifier()
      : super(
          const PatientProfileData(
            fullName: 'Rahul Kumar',
            patientId: 'ASTH-P-000125',
            isVerified: true,
            dob: '12-05-1997',
            gender: 'Male',
            bloodGroup: 'O+',
            phone: '+91 98765 43210',
            email: 'rahulkumar@gmail.com',
            alternateNumber: '+91 91234 56789',
            address: '123, Green Park, Roorkee, Haridwar Road, Uttarakhand - 247667',
            emergencyName: 'Suresh Kumar',
            emergencyRelationship: 'Father',
            emergencyPhone: '+91 98765 00000',
            height: '175 cm',
            weight: '68 kg',
            bmi: '22.2',
            bmiStatus: 'Normal',
            lastCheckup: '25 May 2025',
            allergies: 'None',
          ),
        );

  void updateProfile(PatientProfileData updated) {
    state = updated;
  }
}
