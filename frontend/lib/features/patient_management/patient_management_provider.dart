import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/patient_record.dart';
import 'patient_management_service.dart';

class PatientManagementState {
  final List<PatientRecord> patients;
  final List<PatientRecord> searchResults;
  final PatientRecord? selectedPatient;
  final String? message;
  final bool isLoading;

  const PatientManagementState({
    required this.patients,
    this.searchResults = const [],
    this.selectedPatient,
    this.message,
    this.isLoading = false,
  });

  PatientManagementState copyWith({
    List<PatientRecord>? patients,
    List<PatientRecord>? searchResults,
    PatientRecord? selectedPatient,
    bool clearSelected = false,
    String? message,
    bool? isLoading,
  }) {
    return PatientManagementState(
      patients: patients ?? this.patients,
      searchResults: searchResults ?? this.searchResults,
      selectedPatient: clearSelected ? null : (selectedPatient ?? this.selectedPatient),
      message: message ?? this.message,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final patientManagementProvider = StateNotifierProvider<PatientManagementNotifier, PatientManagementState>((ref) {
  return PatientManagementNotifier();
});

class PatientManagementNotifier extends StateNotifier<PatientManagementState> {
  final PatientManagementService _service;

  PatientManagementNotifier({PatientManagementService? service})
      : _service = service ?? PatientManagementService(),
        super(PatientManagementState(patients: [])) {
    state = state.copyWith(patients: _service.patients, searchResults: const []);
  }

  Future<void> searchPatients(String query) async {
    state = state.copyWith(isLoading: true);
    final results = _service.searchPatients(query);
    state = state.copyWith(
      isLoading: false,
      searchResults: results,
      selectedPatient: results.isNotEmpty ? results.first : null,
      clearSelected: results.isEmpty,
      message: results.isEmpty ? 'No matching patient found. You can register a new record.' : 'Matching patient records found.',
    );
  }

  Future<PatientRegistrationResult> registerPatient({
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
  }) async {
    state = state.copyWith(isLoading: true);
    final result = _service.registerPatient(
      fullName: fullName,
      gender: gender,
      dateOfBirth: dateOfBirth,
      bloodGroup: bloodGroup,
      mobileNumber: mobileNumber,
      alternateNumber: alternateNumber,
      email: email,
      address: address,
      emergencyContact: emergencyContact,
      medicalHistory: medicalHistory,
      allergies: allergies,
      currentMedications: currentMedications,
      referringDoctor: referringDoctor,
      aadhaarNumber: aadhaarNumber,
    );

    state = state.copyWith(
      isLoading: false,
      patients: _service.patients,
      searchResults: [result.patient],
      selectedPatient: result.patient,
      message: result.message,
    );
    return result;
  }

  void selectPatient(PatientRecord patient) {
    state = state.copyWith(selectedPatient: patient, searchResults: [patient]);
  }
}
