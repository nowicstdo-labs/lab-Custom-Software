enum SampleStatus {
  samplePending,
  sampleCollected,
  receivedInLab,
  processing,
  completed,
}

extension SampleStatusExtension on SampleStatus {
  String get displayName {
    switch (this) {
      case SampleStatus.samplePending:
        return 'Sample Pending';
      case SampleStatus.sampleCollected:
        return 'Sample Collected';
      case SampleStatus.receivedInLab:
        return 'Received in Lab';
      case SampleStatus.processing:
        return 'Processing';
      case SampleStatus.completed:
        return 'Completed';
    }
  }
}

class SampleRecord {
  final String sampleId; // e.g., ASTH-SMP-2026-00451
  final String patientId;
  final String bookingId;
  final String testName;
  final String sampleType;
  final String collectionDate;
  final String collectionTime;
  final String collectedBy;
  final SampleStatus status;
  final String qrToken; // Secure identifier token for QR code

  const SampleRecord({
    required this.sampleId,
    required this.patientId,
    required this.bookingId,
    required this.testName,
    required this.sampleType,
    required this.collectionDate,
    required this.collectionTime,
    required this.collectedBy,
    required this.status,
    required this.qrToken,
  });

  SampleRecord copyWith({
    String? sampleId,
    String? patientId,
    String? bookingId,
    String? testName,
    String? sampleType,
    String? collectionDate,
    String? collectionTime,
    String? collectedBy,
    SampleStatus? status,
    String? qrToken,
  }) {
    return SampleRecord(
      sampleId: sampleId ?? this.sampleId,
      patientId: patientId ?? this.patientId,
      bookingId: bookingId ?? this.bookingId,
      testName: testName ?? this.testName,
      sampleType: sampleType ?? this.sampleType,
      collectionDate: collectionDate ?? this.collectionDate,
      collectionTime: collectionTime ?? this.collectionTime,
      collectedBy: collectedBy ?? this.collectedBy,
      status: status ?? this.status,
      qrToken: qrToken ?? this.qrToken,
    );
  }
}
