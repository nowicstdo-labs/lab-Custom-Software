enum ParameterFlag {
  normal,
  high,
  low,
  critical,
}

extension ParameterFlagExtension on ParameterFlag {
  String get displayName {
    switch (this) {
      case ParameterFlag.normal:
        return 'Normal';
      case ParameterFlag.high:
        return 'High';
      case ParameterFlag.low:
        return 'Low';
      case ParameterFlag.critical:
        return 'Critical';
    }
  }
}

class TestResultParameter {
  final String parameterName;
  final String resultValue;
  final String unit;
  final String referenceRange;
  final ParameterFlag flag;
  final String remark;

  const TestResultParameter({
    required this.parameterName,
    required this.resultValue,
    required this.unit,
    required this.referenceRange,
    this.flag = ParameterFlag.normal,
    this.remark = '',
  });

  TestResultParameter copyWith({
    String? parameterName,
    String? resultValue,
    String? unit,
    String? referenceRange,
    ParameterFlag? flag,
    String? remark,
  }) {
    return TestResultParameter(
      parameterName: parameterName ?? this.parameterName,
      resultValue: resultValue ?? this.resultValue,
      unit: unit ?? this.unit,
      referenceRange: referenceRange ?? this.referenceRange,
      flag: flag ?? this.flag,
      remark: remark ?? this.remark,
    );
  }
}

class TestResult {
  final String resultId;
  final String bookingId;
  final String sampleId;
  final String patientId;
  final String testName;
  final List<TestResultParameter> parameters;
  final String enteredBy;
  final String enteredAt;
  final String overallRemarks;

  const TestResult({
    required this.resultId,
    required this.bookingId,
    required this.sampleId,
    required this.patientId,
    required this.testName,
    required this.parameters,
    required this.enteredBy,
    required this.enteredAt,
    this.overallRemarks = '',
  });
}
