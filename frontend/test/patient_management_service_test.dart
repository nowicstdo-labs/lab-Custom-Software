import 'package:flutter_test/flutter_test.dart';
import 'package:astha_diagnostic/features/patient_management/patient_management_service.dart';

void main() {
  group('PatientManagementService', () {
    test('generates a unique patient id and prevents duplicates', () {
      final service = PatientManagementService();
      final first = service.registerPatient(
        fullName: 'Aditi Rao',
        gender: 'Female',
        dateOfBirth: DateTime(1991, 3, 10),
        bloodGroup: 'A+',
        mobileNumber: '+919999111222',
        address: '1 Main Street',
      );

      expect(first.created, isTrue);
      expect(first.patient.patientId, contains('AD-'));

      final duplicate = service.registerPatient(
        fullName: 'Aditi Rao Duplicate',
        gender: 'Female',
        dateOfBirth: DateTime(1991, 3, 10),
        bloodGroup: 'A+',
        mobileNumber: '+919999111222',
        address: '1 Main Street',
      );

      expect(duplicate.duplicateFound, isTrue);
      expect(duplicate.created, isFalse);
    });

    test('finds matching patients by name, mobile or aadhaar', () {
      final service = PatientManagementService();
      final results = service.searchPatients('Nidhi');
      expect(results, isNotEmpty);
      expect(results.first.fullName, contains('Nidhi'));
    });
  });
}
