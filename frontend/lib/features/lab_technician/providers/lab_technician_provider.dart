import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/assigned_test_model.dart';
import '../models/sample_model.dart';
import '../models/test_result_model.dart';

class TechNotification {
  final String id;
  final String title;
  final String message;
  final String timestamp;
  final IconData icon;
  final Color color;
  final bool isRead;

  const TechNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.icon,
    required this.color,
    this.isRead = false,
  });

  TechNotification copyWith({bool? isRead}) {
    return TechNotification(
      id: id,
      title: title,
      message: message,
      timestamp: timestamp,
      icon: icon,
      color: color,
      isRead: isRead ?? this.isRead,
    );
  }
}

class TechProfile {
  final String name;
  final String email;
  final String phone;
  final String employeeId;
  final String department;
  final String role;
  final bool isOnline;

  const TechProfile({
    required this.name,
    required this.email,
    required this.phone,
    required this.employeeId,
    required this.department,
    required this.role,
    this.isOnline = true,
  });

  TechProfile copyWith({
    String? name,
    String? email,
    String? phone,
    String? employeeId,
    String? department,
    String? role,
    bool? isOnline,
  }) {
    return TechProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      employeeId: employeeId ?? this.employeeId,
      department: department ?? this.department,
      role: role ?? this.role,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}

class LabTechnicianState {
  final List<AssignedTest> assignedTests;
  final List<TechSampleItem> samples;
  final List<DynamicTestResultRecord> results;
  final List<TechNotification> notifications;
  final TechProfile profile;
  final String searchQuery;
  final String selectedStatusFilter;
  final String selectedTestFilter;
  final ThemeMode themeMode;

  const LabTechnicianState({
    required this.assignedTests,
    required this.samples,
    required this.results,
    required this.notifications,
    required this.profile,
    this.searchQuery = '',
    this.selectedStatusFilter = 'All Status',
    this.selectedTestFilter = 'All Tests',
    this.themeMode = ThemeMode.light,
  });

  LabTechnicianState copyWith({
    List<AssignedTest>? assignedTests,
    List<TechSampleItem>? samples,
    List<DynamicTestResultRecord>? results,
    List<TechNotification>? notifications,
    TechProfile? profile,
    String? searchQuery,
    String? selectedStatusFilter,
    String? selectedTestFilter,
    ThemeMode? themeMode,
  }) {
    return LabTechnicianState(
      assignedTests: assignedTests ?? this.assignedTests,
      samples: samples ?? this.samples,
      results: results ?? this.results,
      notifications: notifications ?? this.notifications,
      profile: profile ?? this.profile,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedStatusFilter: selectedStatusFilter ?? this.selectedStatusFilter,
      selectedTestFilter: selectedTestFilter ?? this.selectedTestFilter,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  int get assignedCount => assignedTests.length;
  int get pendingCount => assignedTests.where((t) => t.status == AssignedTestStatus.pending).length;
  int get inProgressCount => assignedTests.where((t) => t.status == AssignedTestStatus.inProgress).length;
  int get completedTodayCount => assignedTests.where((t) => t.status == AssignedTestStatus.completed).length;
  int get unreadNotificationCount => notifications.where((n) => !n.isRead).length;

  List<AssignedTest> get filteredTests {
    return assignedTests.where((test) {
      final matchesSearch = searchQuery.isEmpty ||
          test.patientName.toLowerCase().contains(searchQuery.toLowerCase()) ||
          test.patientId.toLowerCase().contains(searchQuery.toLowerCase()) ||
          test.sampleId.toLowerCase().contains(searchQuery.toLowerCase()) ||
          test.testName.toLowerCase().contains(searchQuery.toLowerCase());

      final matchesStatus = selectedStatusFilter == 'All Status' ||
          test.status.displayName.toLowerCase() == selectedStatusFilter.toLowerCase();

      final matchesTest = selectedTestFilter == 'All Tests' ||
          test.testName.toLowerCase().contains(selectedTestFilter.toLowerCase());

      return matchesSearch && matchesStatus && matchesTest;
    }).toList();
  }
}

final labTechnicianProvider = StateNotifierProvider<LabTechnicianNotifier, LabTechnicianState>((ref) {
  return LabTechnicianNotifier();
});

class LabTechnicianNotifier extends StateNotifier<LabTechnicianState> {
  LabTechnicianNotifier() : super(_initialData());

  static LabTechnicianState _initialData() {
    final todayStr = DateFormat('13 May 2025').format(DateTime.now());

    final initialAssignedTests = [
      AssignedTest(
        testId: 'T10024',
        testName: 'CBC (Complete Blood Count)',
        category: 'Hematology',
        sampleId: 'SMP10024',
        sampleType: 'Whole Blood',
        patientId: 'P10024',
        patientName: 'Amit Verma',
        patientAgeGender: '32 Years / Male',
        patientPhone: '9876543210',
        priority: TestPriority.high,
        status: AssignedTestStatus.sampleCollected,
        appointmentDate: todayStr,
        appointmentTime: '10:30 AM',
        assignedTechnician: 'Rohit Sharma',
      ),
      AssignedTest(
        testId: 'T10025',
        testName: 'Lipid Profile',
        category: 'Biochemistry',
        sampleId: 'SMP10025',
        sampleType: 'Serum',
        patientId: 'P10025',
        patientName: 'Neha Singh',
        patientAgeGender: '28 Years / Female',
        patientPhone: '9876543211',
        priority: TestPriority.normal,
        status: AssignedTestStatus.inProgress,
        appointmentDate: todayStr,
        appointmentTime: '09:15 AM',
        assignedTechnician: 'Rohit Sharma',
      ),
      AssignedTest(
        testId: 'T10026',
        testName: 'Blood Glucose (F)',
        category: 'Biochemistry',
        sampleId: 'SMP10026',
        sampleType: 'Plasma',
        patientId: 'P10026',
        patientName: 'Rajesh Kumar',
        patientAgeGender: '45 Years / Male',
        patientPhone: '9876543212',
        priority: TestPriority.high,
        status: AssignedTestStatus.pending,
        appointmentDate: todayStr,
        appointmentTime: '11:00 AM',
        assignedTechnician: 'Rohit Sharma',
      ),
      AssignedTest(
        testId: 'T10027',
        testName: 'Thyroid Profile',
        category: 'Endocrinology',
        sampleId: 'SMP10027',
        sampleType: 'Serum',
        patientId: 'P10027',
        patientName: 'Pooja Patel',
        patientAgeGender: '30 Years / Female',
        patientPhone: '9876543213',
        priority: TestPriority.normal,
        status: AssignedTestStatus.resultEntered,
        appointmentDate: todayStr,
        appointmentTime: '12:20 PM',
        assignedTechnician: 'Rohit Sharma',
      ),
      AssignedTest(
        testId: 'T10028',
        testName: 'Liver Function Test',
        category: 'Biochemistry',
        sampleId: 'SMP10028',
        sampleType: 'Serum',
        patientId: 'P10028',
        patientName: 'Sanjay Mehta',
        patientAgeGender: '50 Years / Male',
        patientPhone: '9876543214',
        priority: TestPriority.high,
        status: AssignedTestStatus.pending,
        appointmentDate: todayStr,
        appointmentTime: '01:15 PM',
        assignedTechnician: 'Rohit Sharma',
      ),
      AssignedTest(
        testId: 'T10029',
        testName: 'Kidney Function Test',
        category: 'Biochemistry',
        sampleId: 'SMP10029',
        sampleType: 'Serum',
        patientId: 'P10029',
        patientName: 'Ananya Roy',
        patientAgeGender: '38 Years / Female',
        patientPhone: '9876543215',
        priority: TestPriority.normal,
        status: AssignedTestStatus.completed,
        appointmentDate: todayStr,
        appointmentTime: '08:00 AM',
        assignedTechnician: 'Rohit Sharma',
      ),
    ];

    final initialSamples = [
      const TechSampleItem(
        sampleId: 'SMP10024',
        patientId: 'P10024',
        patientName: 'Amit Verma',
        patientAgeGender: '32 Y / M',
        testName: 'CBC (Complete Blood Count)',
        sampleType: 'Whole Blood',
        collectionTime: '10:00 AM',
        receivedTime: '10:25 AM',
        stage: TechSampleStage.sampleCollected,
      ),
      const TechSampleItem(
        sampleId: 'SMP10025',
        patientId: 'P10025',
        patientName: 'Neha Singh',
        patientAgeGender: '28 Y / F',
        testName: 'Lipid Profile',
        sampleType: 'Serum',
        collectionTime: '09:00 AM',
        receivedTime: '09:15 AM',
        stage: TechSampleStage.processing,
      ),
      const TechSampleItem(
        sampleId: 'SMP10026',
        patientId: 'P10026',
        patientName: 'Rajesh Kumar',
        patientAgeGender: '45 Y / M',
        testName: 'Blood Glucose (F)',
        sampleType: 'Plasma',
        collectionTime: '10:45 AM',
        receivedTime: '11:00 AM',
        stage: TechSampleStage.sampleReceived,
      ),
      const TechSampleItem(
        sampleId: 'SMP10027',
        patientId: 'P10027',
        patientName: 'Pooja Patel',
        patientAgeGender: '30 Y / F',
        testName: 'Thyroid Profile',
        sampleType: 'Serum',
        collectionTime: '11:50 AM',
        receivedTime: '12:05 PM',
        stage: TechSampleStage.resultEntered,
      ),
      const TechSampleItem(
        sampleId: 'SMP10028',
        patientId: 'P10028',
        patientName: 'Sanjay Mehta',
        patientAgeGender: '50 Y / M',
        testName: 'Liver Function Test',
        sampleType: 'Serum',
        collectionTime: '12:30 PM',
        receivedTime: '01:00 PM',
        stage: TechSampleStage.sampleCollected,
      ),
      const TechSampleItem(
        sampleId: 'SMP10029',
        patientId: 'P10029',
        patientName: 'Ananya Roy',
        patientAgeGender: '38 Y / F',
        testName: 'Kidney Function Test',
        sampleType: 'Serum',
        collectionTime: '07:30 AM',
        receivedTime: '07:45 AM',
        stage: TechSampleStage.completed,
      ),
    ];

    // Initial CBC result preset for SMP10024 (Amit Verma) matching reference UI
    final initialResults = [
      DynamicTestResultRecord(
        resultId: 'R10024',
        sampleId: 'SMP10024',
        patientId: 'P10024',
        patientName: 'Amit Verma',
        patientAgeGender: '32 Years / Male',
        doctorName: 'Dr. Ankit Gupta',
        testName: 'CBC (Complete Blood Count)',
        sampleType: 'Whole Blood',
        remarks: 'All parameters are within normal range.',
        technicianName: 'Rohit Sharma',
        testDate: '13 May 2025 02:15 PM',
        isDraft: true,
        isCompleted: false,
        parameters: const [
          DynamicTestParameter(parameterName: 'Hemoglobin (Hb)', resultValue: '13.8', unit: 'g/dL', referenceRange: '13.0 - 17.0', minVal: 13.0, maxVal: 17.0, status: ResultStatusFlag.normal),
          DynamicTestParameter(parameterName: 'RBC Count', resultValue: '5.02', unit: 'million/µL', referenceRange: '4.5 - 5.9', minVal: 4.5, maxVal: 5.9, status: ResultStatusFlag.normal),
          DynamicTestParameter(parameterName: 'WBC Count', resultValue: '8600', unit: '/µL', referenceRange: '4,000 - 11,000', minVal: 4000, maxVal: 11000, status: ResultStatusFlag.normal),
          DynamicTestParameter(parameterName: 'Platelets', resultValue: '2.45', unit: 'lakh/µL', referenceRange: '1.5 - 4.1', minVal: 1.5, maxVal: 4.1, status: ResultStatusFlag.normal),
          DynamicTestParameter(parameterName: 'Hematocrit (HCT)', resultValue: '41.2', unit: '%', referenceRange: '40 - 50', minVal: 40.0, maxVal: 50.0, status: ResultStatusFlag.normal),
          DynamicTestParameter(parameterName: 'MCV', resultValue: '82.1', unit: 'fL', referenceRange: '80 - 96', minVal: 80.0, maxVal: 96.0, status: ResultStatusFlag.normal),
          DynamicTestParameter(parameterName: 'MCH', resultValue: '27.5', unit: 'pg', referenceRange: '27 - 32', minVal: 27.0, maxVal: 32.0, status: ResultStatusFlag.normal),
          DynamicTestParameter(parameterName: 'MCHC', resultValue: '33.5', unit: 'g/dL', referenceRange: '32 - 36', minVal: 32.0, maxVal: 36.0, status: ResultStatusFlag.normal),
        ],
      ),
    ];

    final initialNotifications = [
      const TechNotification(
        id: 'N1',
        title: 'New Urgent Test Assigned',
        message: 'CBC Test (SMP10024) for Amit Verma marked High Priority.',
        timestamp: '10 mins ago',
        icon: Icons.priority_high,
        color: Color(0xFFEF4444),
      ),
      const TechNotification(
        id: 'N2',
        title: 'Sample Received in Lab',
        message: 'Blood Glucose sample (SMP10026) arrived at workstation 2.',
        timestamp: '25 mins ago',
        icon: Icons.biotech,
        color: Color(0xFF2563EB),
      ),
      const TechNotification(
        id: 'N3',
        title: 'Result Correction Requested',
        message: 'Pathologist requested review on Lipid Profile (SMP10025).',
        timestamp: '1 hour ago',
        icon: Icons.rate_review,
        color: Color(0xFFF59E0B),
      ),
      const TechNotification(
        id: 'N4',
        title: 'Test Completed Successfully',
        message: 'Kidney Function Test (SMP10029) submitted for report generation.',
        timestamp: '3 hours ago',
        icon: Icons.check_circle,
        color: Color(0xFF10B981),
      ),
    ];

    const initialProfile = TechProfile(
      name: 'Rohit Sharma',
      email: 'rohit.sharma@asthadiagnostic.com',
      phone: '+91 98765 43210',
      employeeId: 'EMP-LAB-204',
      department: 'Pathology & Biochemistry',
      role: 'Lab Technician',
      isOnline: true,
    );

    return LabTechnicianState(
      assignedTests: initialAssignedTests,
      samples: initialSamples,
      results: initialResults,
      notifications: initialNotifications,
      profile: initialProfile,
    );
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setStatusFilter(String status) {
    state = state.copyWith(selectedStatusFilter: status);
  }

  void setTestFilter(String test) {
    state = state.copyWith(selectedTestFilter: test);
  }

  void toggleThemeMode() {
    final next = state.themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    state = state.copyWith(themeMode: next);
  }

  void updateTestStatus(String sampleId, AssignedTestStatus newStatus) {
    final updatedTests = state.assignedTests.map((t) {
      if (t.sampleId == sampleId) {
        return t.copyWith(status: newStatus);
      }
      return t;
    }).toList();

    state = state.copyWith(assignedTests: updatedTests);
  }

  void updateSampleStage(String sampleId, TechSampleStage newStage) {
    final updatedSamples = state.samples.map((s) {
      if (s.sampleId == sampleId) {
        return s.copyWith(stage: newStage);
      }
      return s;
    }).toList();

    // Map TechSampleStage to AssignedTestStatus
    AssignedTestStatus correspondingStatus = AssignedTestStatus.pending;
    if (newStage == TechSampleStage.sampleCollected || newStage == TechSampleStage.sampleReceived) {
      correspondingStatus = AssignedTestStatus.sampleCollected;
    } else if (newStage == TechSampleStage.processing || newStage == TechSampleStage.testing) {
      correspondingStatus = AssignedTestStatus.inProgress;
    } else if (newStage == TechSampleStage.resultEntered) {
      correspondingStatus = AssignedTestStatus.resultEntered;
    } else if (newStage == TechSampleStage.completed) {
      correspondingStatus = AssignedTestStatus.completed;
    }

    updateTestStatus(sampleId, correspondingStatus);
    state = state.copyWith(samples: updatedSamples);
  }

  void saveTestResultDraft(DynamicTestResultRecord result) {
    final index = state.results.indexWhere((r) => r.sampleId == result.sampleId);
    List<DynamicTestResultRecord> updated;
    final draft = result.copyWith(isDraft: true, isCompleted: false);

    if (index >= 0) {
      updated = List<DynamicTestResultRecord>.from(state.results)..[index] = draft;
    } else {
      updated = [draft, ...state.results];
    }

    updateTestStatus(result.sampleId, AssignedTestStatus.resultEntered);
    updateSampleStage(result.sampleId, TechSampleStage.resultEntered);
    state = state.copyWith(results: updated);
  }

  void markTestCompleted(DynamicTestResultRecord result) {
    final index = state.results.indexWhere((r) => r.sampleId == result.sampleId);
    List<DynamicTestResultRecord> updated;
    final completedRecord = result.copyWith(isDraft: false, isCompleted: true);

    if (index >= 0) {
      updated = List<DynamicTestResultRecord>.from(state.results)..[index] = completedRecord;
    } else {
      updated = [completedRecord, ...state.results];
    }

    updateTestStatus(result.sampleId, AssignedTestStatus.completed);
    updateSampleStage(result.sampleId, TechSampleStage.completed);

    final notice = TechNotification(
      id: 'N-${DateTime.now().millisecondsSinceEpoch}',
      title: 'Test Completed: ${result.testName}',
      message: 'Results for ${result.patientName} (${result.sampleId}) marked Completed.',
      timestamp: 'Just now',
      icon: Icons.check_circle,
      color: const Color(0xFF10B981),
    );

    state = state.copyWith(
      results: updated,
      notifications: [notice, ...state.notifications],
    );
  }

  void markNotificationAsRead(String id) {
    final updated = state.notifications.map((n) {
      if (n.id == id) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();
    state = state.copyWith(notifications: updated);
  }

  void updateProfile({required String name, required String phone, required String email}) {
    final updated = state.profile.copyWith(name: name, phone: phone, email: email);
    state = state.copyWith(profile: updated);
  }

  /// Preset parameters template for standard tests
  List<DynamicTestParameter> getTemplateForTest(String testName) {
    final lower = testName.toLowerCase();
    if (lower.contains('cbc') || lower.contains('complete blood count')) {
      return const [
        DynamicTestParameter(parameterName: 'Hemoglobin (Hb)', resultValue: '13.8', unit: 'g/dL', referenceRange: '13.0 - 17.0', minVal: 13.0, maxVal: 17.0, status: ResultStatusFlag.normal),
        DynamicTestParameter(parameterName: 'RBC Count', resultValue: '5.02', unit: 'million/µL', referenceRange: '4.5 - 5.9', minVal: 4.5, maxVal: 5.9, status: ResultStatusFlag.normal),
        DynamicTestParameter(parameterName: 'WBC Count', resultValue: '8600', unit: '/µL', referenceRange: '4,000 - 11,000', minVal: 4000, maxVal: 11000, status: ResultStatusFlag.normal),
        DynamicTestParameter(parameterName: 'Platelets', resultValue: '2.45', unit: 'lakh/µL', referenceRange: '1.5 - 4.1', minVal: 1.5, maxVal: 4.1, status: ResultStatusFlag.normal),
        DynamicTestParameter(parameterName: 'Hematocrit (HCT)', resultValue: '41.2', unit: '%', referenceRange: '40 - 50', minVal: 40.0, maxVal: 50.0, status: ResultStatusFlag.normal),
        DynamicTestParameter(parameterName: 'MCV', resultValue: '82.1', unit: 'fL', referenceRange: '80 - 96', minVal: 80.0, maxVal: 96.0, status: ResultStatusFlag.normal),
        DynamicTestParameter(parameterName: 'MCH', resultValue: '27.5', unit: 'pg', referenceRange: '27 - 32', minVal: 27.0, maxVal: 32.0, status: ResultStatusFlag.normal),
        DynamicTestParameter(parameterName: 'MCHC', resultValue: '33.5', unit: 'g/dL', referenceRange: '32 - 36', minVal: 32.0, maxVal: 36.0, status: ResultStatusFlag.normal),
      ];
    } else if (lower.contains('glucose') || lower.contains('sugar')) {
      return const [
        DynamicTestParameter(parameterName: 'Fasting Blood Glucose', resultValue: '95', unit: 'mg/dL', referenceRange: '70 - 99', minVal: 70.0, maxVal: 99.0, status: ResultStatusFlag.normal),
        DynamicTestParameter(parameterName: 'HbA1c', resultValue: '5.6', unit: '%', referenceRange: '4.0 - 5.6', minVal: 4.0, maxVal: 5.6, status: ResultStatusFlag.normal),
      ];
    } else if (lower.contains('lipid')) {
      return const [
        DynamicTestParameter(parameterName: 'Total Cholesterol', resultValue: '185', unit: 'mg/dL', referenceRange: '< 200', maxVal: 200.0, status: ResultStatusFlag.normal),
        DynamicTestParameter(parameterName: 'Triglycerides', resultValue: '140', unit: 'mg/dL', referenceRange: '< 150', maxVal: 150.0, status: ResultStatusFlag.normal),
        DynamicTestParameter(parameterName: 'HDL Cholesterol', resultValue: '52', unit: 'mg/dL', referenceRange: '> 40', minVal: 40.0, status: ResultStatusFlag.normal),
        DynamicTestParameter(parameterName: 'LDL Cholesterol', resultValue: '105', unit: 'mg/dL', referenceRange: '< 100', maxVal: 100.0, status: ResultStatusFlag.high),
      ];
    } else if (lower.contains('thyroid')) {
      return const [
        DynamicTestParameter(parameterName: 'Total T3', resultValue: '1.25', unit: 'ng/mL', referenceRange: '0.80 - 2.00', minVal: 0.80, maxVal: 2.00, status: ResultStatusFlag.normal),
        DynamicTestParameter(parameterName: 'Total T4', resultValue: '8.4', unit: 'µg/dL', referenceRange: '5.1 - 14.1', minVal: 5.1, maxVal: 14.1, status: ResultStatusFlag.normal),
        DynamicTestParameter(parameterName: 'TSH', resultValue: '2.15', unit: 'µIU/mL', referenceRange: '0.27 - 4.20', minVal: 0.27, maxVal: 4.20, status: ResultStatusFlag.normal),
      ];
    } else {
      return const [
        DynamicTestParameter(parameterName: 'Primary Parameter', resultValue: '100', unit: 'IU/L', referenceRange: '50 - 150', minVal: 50.0, maxVal: 150.0, status: ResultStatusFlag.normal),
      ];
    }
  }
}
