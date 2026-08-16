import 'dart:async';
import '../features/auth/auth_models.dart';
import '../models/health_package.dart';
import '../models/lab_test.dart';
import '../models/appointment.dart';
import '../models/notification_item.dart';
import '../utils/dummy_data.dart';

class MockApiService {
  const MockApiService();

  Future<List<HealthPackage>> fetchHealthPackages() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return demoHealthPackages;
  }

  Future<List<LabTest>> fetchLabTests() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return demoLabTests;
  }

  Future<List<Appointment>> fetchUpcomingAppointments(UserRole role) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return demoAppointments;
  }

  Future<List<NotificationItem>> fetchNotifications() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return demoNotifications;
  }
}
