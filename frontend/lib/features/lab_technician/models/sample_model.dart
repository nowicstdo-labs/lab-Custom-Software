enum TechSampleStage {
  sampleCollected,
  sampleReceived,
  processing,
  testing,
  resultEntered,
  completed,
}

extension TechSampleStageExtension on TechSampleStage {
  String get displayName {
    switch (this) {
      case TechSampleStage.sampleCollected:
        return 'Sample Collected';
      case TechSampleStage.sampleReceived:
        return 'Sample Received';
      case TechSampleStage.processing:
        return 'Processing';
      case TechSampleStage.testing:
        return 'Testing';
      case TechSampleStage.resultEntered:
        return 'Result Entered';
      case TechSampleStage.completed:
        return 'Completed';
    }
  }

  int get stepIndex {
    switch (this) {
      case TechSampleStage.sampleCollected:
        return 0;
      case TechSampleStage.sampleReceived:
        return 1;
      case TechSampleStage.processing:
        return 2;
      case TechSampleStage.testing:
        return 3;
      case TechSampleStage.resultEntered:
        return 4;
      case TechSampleStage.completed:
        return 5;
    }
  }
}

class TechSampleItem {
  final String sampleId;
  final String patientId;
  final String patientName;
  final String patientAgeGender;
  final String testName;
  final String sampleType;
  final String collectionTime;
  final String receivedTime;
  final TechSampleStage stage;

  const TechSampleItem({
    required this.sampleId,
    required this.patientId,
    required this.patientName,
    required this.patientAgeGender,
    required this.testName,
    required this.sampleType,
    required this.collectionTime,
    required this.receivedTime,
    required this.stage,
  });

  TechSampleItem copyWith({
    String? sampleId,
    String? patientId,
    String? patientName,
    String? patientAgeGender,
    String? testName,
    String? sampleType,
    String? collectionTime,
    String? receivedTime,
    TechSampleStage? stage,
  }) {
    return TechSampleItem(
      sampleId: sampleId ?? this.sampleId,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      patientAgeGender: patientAgeGender ?? this.patientAgeGender,
      testName: testName ?? this.testName,
      sampleType: sampleType ?? this.sampleType,
      collectionTime: collectionTime ?? this.collectionTime,
      receivedTime: receivedTime ?? this.receivedTime,
      stage: stage ?? this.stage,
    );
  }
}
