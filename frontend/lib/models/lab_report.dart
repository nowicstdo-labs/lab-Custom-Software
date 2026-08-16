import 'test_result.dart';

enum ReportStatus {
  draft,
  readyForVerification,
  approved,
  finalized,
  rejected,
}

extension ReportStatusExtension on ReportStatus {
  String get displayName {
    switch (this) {
      case ReportStatus.draft:
        return 'Draft';
      case ReportStatus.readyForVerification:
        return 'Ready for Verification';
      case ReportStatus.approved:
        return 'Approved';
      case ReportStatus.finalized:
        return 'Final';
      case ReportStatus.rejected:
        return 'Rejected';
    }
  }
}

class LabReport {
  final String reportId; // e.g. ASTH-RPT-2026-00125
  final String bookingId;
  final String sampleId;
  final String patientId;
  final String patientName;
  final String patientAgeGender;
  final String testName;
  final String sampleType;
  final String collectionDate;
  final String reportDate;
  final List<TestResultParameter> parameters;
  final ReportStatus status;
  final String doctorPathologistName;
  final String doctorQualifications;
  final String? approvedBy;
  final String? approvedAt;
  final String? rejectionReason;
  final String qrToken; // Token encoded into QR for authenticity verification

  const LabReport({
    required this.reportId,
    required this.bookingId,
    required this.sampleId,
    required this.patientId,
    required this.patientName,
    required this.patientAgeGender,
    required this.testName,
    required this.sampleType,
    required this.collectionDate,
    required this.reportDate,
    required this.parameters,
    required this.status,
    required this.doctorPathologistName,
    required this.doctorQualifications,
    this.approvedBy,
    this.approvedAt,
    this.rejectionReason,
    required this.qrToken,
  });

  LabReport copyWith({
    String? reportId,
    String? bookingId,
    String? sampleId,
    String? patientId,
    String? patientName,
    String? patientAgeGender,
    String? testName,
    String? sampleType,
    String? collectionDate,
    String? reportDate,
    List<TestResultParameter>? parameters,
    ReportStatus? status,
    String? doctorPathologistName,
    String? doctorQualifications,
    String? approvedBy,
    String? approvedAt,
    String? rejectionReason,
    String? qrToken,
  }) {
    return LabReport(
      reportId: reportId ?? this.reportId,
      bookingId: bookingId ?? this.bookingId,
      sampleId: sampleId ?? this.sampleId,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      patientAgeGender: patientAgeGender ?? this.patientAgeGender,
      testName: testName ?? this.testName,
      sampleType: sampleType ?? this.sampleType,
      collectionDate: collectionDate ?? this.collectionDate,
      reportDate: reportDate ?? this.reportDate,
      parameters: parameters ?? this.parameters,
      status: status ?? this.status,
      doctorPathologistName: doctorPathologistName ?? this.doctorPathologistName,
      doctorQualifications: doctorQualifications ?? this.doctorQualifications,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      qrToken: qrToken ?? this.qrToken,
    );
  }
}
