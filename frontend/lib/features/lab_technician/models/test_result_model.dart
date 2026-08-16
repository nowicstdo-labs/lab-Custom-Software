enum ResultStatusFlag {
  normal,
  high,
  low,
  critical,
}

extension ResultStatusFlagExtension on ResultStatusFlag {
  String get displayName {
    switch (this) {
      case ResultStatusFlag.normal:
        return 'Normal';
      case ResultStatusFlag.high:
        return 'High';
      case ResultStatusFlag.low:
        return 'Low';
      case ResultStatusFlag.critical:
        return 'Critical';
    }
  }
}

class DynamicTestParameter {
  final String parameterName;
  final String resultValue;
  final String unit;
  final String referenceRange;
  final double? minVal;
  final double? maxVal;
  final ResultStatusFlag status;
  final String remark;

  const DynamicTestParameter({
    required this.parameterName,
    required this.resultValue,
    required this.unit,
    required this.referenceRange,
    this.minVal,
    this.maxVal,
    this.status = ResultStatusFlag.normal,
    this.remark = '',
  });

  DynamicTestParameter copyWith({
    String? parameterName,
    String? resultValue,
    String? unit,
    String? referenceRange,
    double? minVal,
    double? maxVal,
    ResultStatusFlag? status,
    String? remark,
  }) {
    return DynamicTestParameter(
      parameterName: parameterName ?? this.parameterName,
      resultValue: resultValue ?? this.resultValue,
      unit: unit ?? this.unit,
      referenceRange: referenceRange ?? this.referenceRange,
      minVal: minVal ?? this.minVal,
      maxVal: maxVal ?? this.maxVal,
      status: status ?? this.status,
      remark: remark ?? this.remark,
    );
  }
}

class DynamicTestResultRecord {
  final String resultId;
  final String sampleId;
  final String patientId;
  final String patientName;
  final String patientAgeGender;
  final String doctorName;
  final String testName;
  final String sampleType;
  final List<DynamicTestParameter> parameters;
  final String remarks;
  final String technicianName;
  final String testDate;
  final bool isDraft;
  final bool isCompleted;

  const DynamicTestResultRecord({
    required this.resultId,
    required this.sampleId,
    required this.patientId,
    required this.patientName,
    required this.patientAgeGender,
    this.doctorName = 'Dr. Ankit Gupta',
    required this.testName,
    required this.sampleType,
    required this.parameters,
    this.remarks = '',
    required this.technicianName,
    required this.testDate,
    this.isDraft = true,
    this.isCompleted = false,
  });

  DynamicTestResultRecord copyWith({
    String? resultId,
    String? sampleId,
    String? patientId,
    String? patientName,
    String? patientAgeGender,
    String? doctorName,
    String? testName,
    String? sampleType,
    List<DynamicTestParameter>? parameters,
    String? remarks,
    String? technicianName,
    String? testDate,
    bool? isDraft,
    bool? isCompleted,
  }) {
    return DynamicTestResultRecord(
      resultId: resultId ?? this.resultId,
      sampleId: sampleId ?? this.sampleId,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      patientAgeGender: patientAgeGender ?? this.patientAgeGender,
      doctorName: doctorName ?? this.doctorName,
      testName: testName ?? this.testName,
      sampleType: sampleType ?? this.sampleType,
      parameters: parameters ?? this.parameters,
      remarks: remarks ?? this.remarks,
      technicianName: technicianName ?? this.technicianName,
      testDate: testDate ?? this.testDate,
      isDraft: isDraft ?? this.isDraft,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
