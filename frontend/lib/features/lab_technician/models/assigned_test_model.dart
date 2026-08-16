enum TestPriority {
  low,
  normal,
  high,
}

extension TestPriorityExtension on TestPriority {
  String get displayName {
    switch (this) {
      case TestPriority.low:
        return 'Low';
      case TestPriority.normal:
        return 'Normal';
      case TestPriority.high:
        return 'High';
    }
  }
}

enum AssignedTestStatus {
  pending,
  sampleCollected,
  inProgress,
  resultEntered,
  completed,
}

extension AssignedTestStatusExtension on AssignedTestStatus {
  String get displayName {
    switch (this) {
      case AssignedTestStatus.pending:
        return 'Pending';
      case AssignedTestStatus.sampleCollected:
        return 'Sample Collected';
      case AssignedTestStatus.inProgress:
        return 'In Progress';
      case AssignedTestStatus.resultEntered:
        return 'Result Entered';
      case AssignedTestStatus.completed:
        return 'Completed';
    }
  }
}

class AssignedTest {
  final String testId;
  final String testName;
  final String category;
  final String sampleId;
  final String sampleType;
  final String patientId;
  final String patientName;
  final String patientAgeGender;
  final String patientPhone;
  final TestPriority priority;
  final AssignedTestStatus status;
  final String appointmentDate;
  final String appointmentTime;
  final String assignedTechnician;

  const AssignedTest({
    required this.testId,
    required this.testName,
    required this.category,
    required this.sampleId,
    required this.sampleType,
    required this.patientId,
    required this.patientName,
    required this.patientAgeGender,
    required this.patientPhone,
    required this.priority,
    required this.status,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.assignedTechnician,
  });

  AssignedTest copyWith({
    String? testId,
    String? testName,
    String? category,
    String? sampleId,
    String? sampleType,
    String? patientId,
    String? patientName,
    String? patientAgeGender,
    String? patientPhone,
    TestPriority? priority,
    AssignedTestStatus? status,
    String? appointmentDate,
    String? appointmentTime,
    String? assignedTechnician,
  }) {
    return AssignedTest(
      testId: testId ?? this.testId,
      testName: testName ?? this.testName,
      category: category ?? this.category,
      sampleId: sampleId ?? this.sampleId,
      sampleType: sampleType ?? this.sampleType,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      patientAgeGender: patientAgeGender ?? this.patientAgeGender,
      patientPhone: patientPhone ?? this.patientPhone,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      appointmentTime: appointmentTime ?? this.appointmentTime,
      assignedTechnician: assignedTechnician ?? this.assignedTechnician,
    );
  }
}
