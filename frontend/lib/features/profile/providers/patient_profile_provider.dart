import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/api_service.dart';

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

  const PatientProfileData.empty()
      : fullName = '',
        patientId = '',
        isVerified = false,
        dob = '',
        gender = '',
        bloodGroup = '',
        phone = '',
        email = '',
        alternateNumber = '',
        address = '',
        emergencyName = '',
        emergencyRelationship = '',
        emergencyPhone = '',
        height = '',
        weight = '',
        bmi = '',
        bmiStatus = '',
        lastCheckup = '',
        allergies = '';

  PatientProfileData copyWith({
    String? fullName,
    String? patientId,
    bool? isVerified,
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
    String? height,
    String? weight,
    String? bmi,
    String? bmiStatus,
    String? lastCheckup,
    String? allergies,
  }) {
    return PatientProfileData(
      fullName: fullName ?? this.fullName,
      patientId: patientId ?? this.patientId,
      isVerified: isVerified ?? this.isVerified,
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
      height: height ?? this.height,
      weight: weight ?? this.weight,
      bmi: bmi ?? this.bmi,
      bmiStatus: bmiStatus ?? this.bmiStatus,
      lastCheckup: lastCheckup ?? this.lastCheckup,
      allergies: allergies ?? this.allergies,
    );
  }
}

final patientProfileProvider =
    StateNotifierProvider<PatientProfileNotifier, PatientProfileData>((ref) {
  return PatientProfileNotifier();
});

class PatientProfileNotifier extends StateNotifier<PatientProfileData> {
  PatientProfileNotifier() : super(const PatientProfileData.empty());

  void updateProfile(PatientProfileData updated) {
    state = updated;
  }

  void setProfileFromUser({required String name, required String email, String? phone}) {
    state = state.copyWith(
      fullName: name,
      email: email,
      phone: phone ?? state.phone,
      isVerified: true,
    );
  }

  void clearProfile() {
    state = const PatientProfileData.empty();
  }

  Future<void> fetchPatientProfile({bool forceRefresh = false}) async {
    if (!forceRefresh && state.fullName.isNotEmpty && state.patientId.isNotEmpty) {
      return;
    }
    try {

      final res = await ApiService.get('/patients/me');
      if (res['success'] == true && res['data'] != null) {
        final data = res['data'] as Map<String, dynamic>;
        final user = data['user'] as Map<String, dynamic>? ?? {};

        final name = user['name'] as String? ?? state.fullName;
        final email = user['email'] as String? ?? state.email;
        final phone = user['phone'] as String? ?? data['phone'] as String? ?? state.phone;
        final patientId = data['patientId'] as String? ?? state.patientId;
        final dob = data['dob'] as String? ?? state.dob;
        final gender = data['gender'] as String? ?? state.gender;
        final bloodGroup = data['bloodGroup'] as String? ?? state.bloodGroup;
        final address = data['address'] as String? ?? state.address;
        final alternateNumber = data['alternateNumber'] as String? ?? state.alternateNumber;
        final emergencyName = data['emergencyName'] as String? ?? state.emergencyName;
        final emergencyRelationship = data['emergencyRelationship'] as String? ?? state.emergencyRelationship;
        final emergencyPhone = data['emergencyPhone'] as String? ?? state.emergencyPhone;

        state = PatientProfileData(
          fullName: name,
          patientId: patientId.isNotEmpty ? patientId : 'ASTH-P-LIVE',
          isVerified: true,
          dob: dob,
          gender: gender,
          bloodGroup: bloodGroup,
          phone: phone,
          email: email,
          alternateNumber: alternateNumber,
          address: address,
          emergencyName: emergencyName,
          emergencyRelationship: emergencyRelationship,
          emergencyPhone: emergencyPhone,
          height: state.height,
          weight: state.weight,
          bmi: state.bmi,
          bmiStatus: state.bmiStatus,
          lastCheckup: state.lastCheckup,
          allergies: state.allergies,
        );
      }
    } catch (_) {}
  }
}

