import 'package:flutter_test/flutter_test.dart';
import 'package:astha_diagnostic/frontend_app.dart';

void main() {
  group('Astha Diagnostic - Authentication & Role Tests', () {
    test('Authenticate valid credentials returns correct user and role', () {
      final patient = MockUserDatabase.authenticate('patient@astha.com', 'password');
      expect(patient, isNotNull);
      expect(patient!.role, equals(UserRole.patient));
      expect(patient.defaultDashboardPath, equals('/patient'));

      final labTech = MockUserDatabase.authenticate('labtech@astha.com', 'password');
      expect(labTech, isNotNull);
      expect(labTech!.role, equals(UserRole.labTechnician));
      expect(labTech.defaultDashboardPath, equals('/lab-tech'));

      final receptionist = MockUserDatabase.authenticate('receptionist@astha.com', 'password');
      expect(receptionist, isNotNull);
      expect(receptionist!.role, equals(UserRole.receptionist));
      expect(receptionist.defaultDashboardPath, equals('/receptionist'));

      final doctor = MockUserDatabase.authenticate('doctor@astha.com', 'password');
      expect(doctor, isNotNull);
      expect(doctor!.role, equals(UserRole.doctor));
      expect(doctor.defaultDashboardPath, equals('/doctor'));

      final admin = MockUserDatabase.authenticate('admin@asthadiagnostic.com', 'Admin@123');
      expect(admin, isNotNull);
      expect(admin!.role, equals(UserRole.admin));
      expect(admin.defaultDashboardPath, equals('/admin'));
    });

    test('Invalid login returns null', () {
      final invalid = MockUserDatabase.authenticate('unknown@astha.com', 'wrongpassword');
      expect(invalid, isNull);
    });

    test('Public registration automatically assigns Patient role without dropdown', () {
      final registered = MockUserDatabase.registerPatient('Test Patient', 'newpatient@astha.com', 'pass123');
      expect(registered.role, equals(UserRole.patient));
      expect(registered.email, equals('newpatient@astha.com'));

      final authenticated = MockUserDatabase.authenticate('newpatient@astha.com', 'pass123');
      expect(authenticated, isNotNull);
      expect(authenticated!.role, equals(UserRole.patient));
    });

    test('Admin staff creation allows creating staff accounts that can immediately log in', () {
      final staff = MockUserDatabase.addStaffMember('New Lab Tech', 'newtech@astha.com', 'techpass', UserRole.labTechnician);
      expect(staff.role, equals(UserRole.labTechnician));

      final loginStaff = MockUserDatabase.authenticate('newtech@astha.com', 'techpass');
      expect(loginStaff, isNotNull);
      expect(loginStaff!.role, equals(UserRole.labTechnician));
    });
  });

  group('Astha Diagnostic - Booking & Slot Capacity Tests', () {
    test('Slot capacity maximum limit of 10 enforcement', () {
      final state = AsthaSharedState(
        bookings: [],
        slotBookingsCount: {
          '10:00 AM': 5,
          '11:00 AM': 10,
        },
      );

      expect(state.isSlotFull('10:00 AM'), isFalse);
      expect(state.getSlotBookedCount('10:00 AM'), equals(5));

      expect(state.isSlotFull('11:00 AM'), isTrue);
      expect(state.getSlotBookedCount('11:00 AM'), equals(10));
    });

    test('Adding a booking increments slot booked count', () async {
      final notifier = SharedDataNotifier();
      final initialCount = notifier.currentState.getSlotBookedCount('09:00 AM');

      await notifier.addBooking(const TestBooking(
        bookingId: 'ASTH-BK-TEST',
        patientId: 'ASTH-P-999',
        patientName: 'Unit Test Patient',
        patientDob: '01-01-2000',
        testName: 'CBC Test',
        appointmentDate: '15-08-2026',
        timeSlot: '09:00 AM',
        price: 450.0,
        status: 'Confirmed',
        sampleStatus: 'Pending',
        reportStatus: 'Awaiting',
      ));

      expect(notifier.currentState.getSlotBookedCount('09:00 AM'), equals(initialCount + 1));
      expect(notifier.currentState.bookings.first.bookingId, equals('ASTH-BK-TEST'));
    });
  });

  group('Astha Diagnostic - Model Serialization Tests', () {
    test('AppUser toJson and fromJson roundtrip', () {
      const user = AppUser(id: 'U1', email: 'test@astha.com', name: 'Test User', role: UserRole.doctor);
      final json = user.toJson();
      final deserialized = AppUser.fromJson(json);

      expect(deserialized.id, equals(user.id));
      expect(deserialized.email, equals(user.email));
      expect(deserialized.name, equals(user.name));
      expect(deserialized.role, equals(user.role));
    });

    test('TestBooking toJson and fromJson roundtrip', () {
      const booking = TestBooking(
        bookingId: 'B1',
        patientId: 'P1',
        patientName: 'John Doe',
        patientDob: '10-10-1990',
        testName: 'Lipid Profile',
        appointmentDate: '15-08-2026',
        timeSlot: '10:30 AM',
        price: 850.0,
        status: 'Confirmed',
        sampleStatus: 'Received',
        reportStatus: 'Ready',
      );
      final json = booking.toJson();
      final deserialized = TestBooking.fromJson(json);

      expect(deserialized.bookingId, equals(booking.bookingId));
      expect(deserialized.price, equals(850.0));
      expect(deserialized.testName, equals('Lipid Profile'));
    });
  });

  group('Astha Diagnostic - Test-Specific Parameter Isolation Tests', () {
    test('Selecting Lipid Profile resets parameters to Lipid Profile only', () {
      final notifier = LabTechNotifier();
      notifier.selectTestParameters('Lipid Profile');

      final activeParams = notifier.state.activeParameters;
      expect(activeParams.length, equals(4));
      expect(activeParams.first.parameterName, equals('Total Cholesterol'));
      expect(activeParams.any((p) => p.parameterName == 'Hemoglobin (Hb)'), isFalse);
    });

    test('Selecting Thyroid Panel resets parameters to Thyroid Panel only', () {
      final notifier = LabTechNotifier();
      notifier.selectTestParameters('Thyroid Panel');

      final activeParams = notifier.state.activeParameters;
      expect(activeParams.length, equals(3));
    });
  });
}
