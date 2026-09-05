// TestBooking data model - API-ready structure for patient booked tests

enum TestStage {
  bookingConfirmed,
  samplePending,
  sampleCollected,
  processing,
  reportReady,
  completed,
  cancelled,
}

class TestBooking {
  final String testId;
  final String testName;
  final String category;
  final String description;
  final String sampleType;
  final double price;
  final String bookingId;
  final String patientId;
  final String patientName;
  final String appointmentDate;
  final String appointmentTime;
  final String bookingStatus; // CONFIRMED, SAMPLE PENDING, SAMPLE COLLECTED, PROCESSING, REPORT READY, COMPLETED, CANCELLED
  final String sampleStatus;
  final String reportStatus;
  final String? sampleCollectionDate;
  final String? sampleCollectionTime;
  final String? reportDate;
  final TestStage currentStage;

  const TestBooking({
    required this.testId,
    required this.testName,
    required this.category,
    required this.description,
    required this.sampleType,
    required this.price,
    required this.bookingId,
    required this.patientId,
    required this.patientName,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.bookingStatus,
    required this.sampleStatus,
    required this.reportStatus,
    this.sampleCollectionDate,
    this.sampleCollectionTime,
    this.reportDate,
    required this.currentStage,
  });

  factory TestBooking.fromBackendJson(Map<String, dynamic> json) {
    final testObj = (json['test'] is Map) ? json['test'] as Map<String, dynamic> : <String, dynamic>{};
    final patientObj = (json['patient'] is Map) ? json['patient'] as Map<String, dynamic> : <String, dynamic>{};
    final userObj = (patientObj['user'] is Map) ? patientObj['user'] as Map<String, dynamic> : <String, dynamic>{};

    final statusStr = (json['status'] ?? 'CONFIRMED').toString().toUpperCase();
    TestStage stage = TestStage.bookingConfirmed;
    if (statusStr == 'PROCESSING') {
      stage = TestStage.processing;
    } else if (statusStr == 'COMPLETED') {
      stage = TestStage.completed;
    } else if (statusStr == 'CANCELLED') {
      stage = TestStage.cancelled;
    }

    final pId = (patientObj['patientId'] ?? json['patientId'] ?? 'ASTH-P-000125').toString();
    final pName = (userObj['name'] ?? patientObj['name'] ?? json['patientName'] ?? 'Patient').toString();

    return TestBooking(
      testId: (json['testId'] ?? testObj['id'] ?? testObj['testId'] ?? '').toString(),
      testName: (testObj['testName'] ?? json['testName'] ?? 'Diagnostic Test').toString(),
      category: (testObj['category'] ?? 'General').toString(),
      description: (testObj['description'] ?? 'Diagnostic test booking.').toString(),
      sampleType: (testObj['sampleType'] ?? 'Blood / Sample').toString(),
      price: _safeToDouble(json['price']) ?? _safeToDouble(testObj['price']) ?? 0.0,
      bookingId: (json['bookingId'] ?? json['id'] ?? '').toString(),
      patientId: pId,
      patientName: pName,
      appointmentDate: (json['appointmentDate'] ?? '').toString(),
      appointmentTime: (json['timeSlot'] ?? json['appointmentTime'] ?? '10:30 AM').toString(),
      bookingStatus: statusStr,
      sampleStatus: 'Sample Collection Pending',
      reportStatus: 'Awaiting Sample Collection',
      currentStage: stage,
    );
  }

  bool get isUpcoming =>
      currentStage == TestStage.bookingConfirmed ||
      currentStage == TestStage.samplePending;

  bool get isInProgress =>
      currentStage == TestStage.sampleCollected ||
      currentStage == TestStage.processing;

  bool get isCompleted =>
      currentStage == TestStage.reportReady ||
      currentStage == TestStage.completed;

  bool get isCancelled => currentStage == TestStage.cancelled;

  bool get isReportAvailable =>
      currentStage == TestStage.reportReady ||
      currentStage == TestStage.completed;

  static double? _safeToDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }
}
