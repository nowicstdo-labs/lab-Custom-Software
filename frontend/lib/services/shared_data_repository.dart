import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/test_booking.dart';
import '../models/sample_record.dart';
import '../models/formula_item.dart';
import '../models/test_result.dart';
import '../models/lab_report.dart';
import '../models/invoice_record.dart';
import '../models/app_notification.dart';
import '../models/audit_log_item.dart';
import '../features/auth/auth_models.dart';
import 'api_service.dart';

// ── TIME SLOT MODEL ─────────────────────────────────────────────────────────

class TimeSlotStatus {
  final String time;
  final int bookedCount;
  final int maxCapacity;

  const TimeSlotStatus({
    required this.time,
    required this.bookedCount,
    this.maxCapacity = 10,
  });

  bool get isFull => bookedCount >= maxCapacity;
  int get availableSlots => (maxCapacity - bookedCount).clamp(0, maxCapacity);
}

// ── REPOSITORY NOTIFIER ─────────────────────────────────────────────────────

class SharedDataState {
  final List<TestBooking> bookings;
  final List<SampleRecord> samples;
  final List<FormulaItem> formulas;
  final List<TestResult> results;
  final List<LabReport> reports;
  final List<InvoiceRecord> invoices;
  final List<AppNotification> notifications;
  final List<AuditLogItem> auditLogs;
  final List<Map<String, dynamic>> recommendedTests; // patientId, testName, doctorName, date
  final Map<String, int> slotBookings; // key: "YYYY-MM-DD_HH:MM AM" -> count

  const SharedDataState({
    required this.bookings,
    required this.samples,
    required this.formulas,
    required this.results,
    required this.reports,
    required this.invoices,
    required this.notifications,
    required this.auditLogs,
    required this.recommendedTests,
    required this.slotBookings,
  });

  SharedDataState copyWith({
    List<TestBooking>? bookings,
    List<SampleRecord>? samples,
    List<FormulaItem>? formulas,
    List<TestResult>? results,
    List<LabReport>? reports,
    List<InvoiceRecord>? invoices,
    List<AppNotification>? notifications,
    List<AuditLogItem>? auditLogs,
    List<Map<String, dynamic>>? recommendedTests,
    Map<String, int>? slotBookings,
  }) {
    return SharedDataState(
      bookings: bookings ?? this.bookings,
      samples: samples ?? this.samples,
      formulas: formulas ?? this.formulas,
      results: results ?? this.results,
      reports: reports ?? this.reports,
      invoices: invoices ?? this.invoices,
      notifications: notifications ?? this.notifications,
      auditLogs: auditLogs ?? this.auditLogs,
      recommendedTests: recommendedTests ?? this.recommendedTests,
      slotBookings: slotBookings ?? this.slotBookings,
    );
  }
}

final sharedDataProvider = StateNotifierProvider<SharedDataNotifier, SharedDataState>((ref) {
  return SharedDataNotifier();
});

class SharedDataNotifier extends StateNotifier<SharedDataState> {
  SharedDataNotifier() : super(_initialData());

  static SharedDataState _initialData() {
    final initialFormulas = [
      const FormulaItem(
        formulaId: 'f1',
        formulaName: 'Indirect Bilirubin',
        formulaExpression: 'TOTAL_BIL - DIRECT_BIL',
        variables: ['TOTAL_BIL', 'DIRECT_BIL'],
        targetTestId: 't2',
        targetTestName: 'Liver Function Test (LFT)',
        unit: 'mg/dL',
        referenceRange: '0.2 - 0.8',
        isActive: true,
      ),
      const FormulaItem(
        formulaId: 'f2',
        formulaName: 'Globulin',
        formulaExpression: 'TOTAL_PROTEIN - ALBUMIN',
        variables: ['TOTAL_PROTEIN', 'ALBUMIN'],
        targetTestId: 't2',
        targetTestName: 'Liver Function Test (LFT)',
        unit: 'g/dL',
        referenceRange: '2.0 - 3.5',
        isActive: true,
      ),
      const FormulaItem(
        formulaId: 'f3',
        formulaName: 'A/G Ratio',
        formulaExpression: 'ALBUMIN / GLOBULIN',
        variables: ['ALBUMIN', 'GLOBULIN'],
        targetTestId: 't2',
        targetTestName: 'Liver Function Test (LFT)',
        unit: 'Ratio',
        referenceRange: '1.1 - 2.2',
        isActive: true,
      ),
    ];

    return SharedDataState(
      bookings: const [],
      samples: const [],
      formulas: initialFormulas,
      results: const [],
      reports: const [],
      invoices: const [],
      notifications: const [],
      auditLogs: const [],
      recommendedTests: const [],
      slotBookings: const {},
    );
  }

  // ── TIME SLOT ACTIONS ─────────────────────────────────────────────────────

  int getSlotBookedCount(String date, String time) {
    final key = '${date}_$time';
    return state.slotBookings[key] ?? 1;
  }

  bool isSlotAvailable(String date, String time) {
    return getSlotBookedCount(date, time) < 10;
  }

  // ── BOOKING ACTIONS ───────────────────────────────────────────────────────

  void setBookings(List<TestBooking> newBookings) {
    state = state.copyWith(bookings: newBookings);
  }

  Future<void> fetchBookingsFromBackend() async {
    try {
      final response = await ApiService.get('/bookings');
      if (response['success'] == true && response['data'] is List) {
        final backendBookings = (response['data'] as List)
            .map((item) => TestBooking.fromBackendJson(item as Map<String, dynamic>))
            .toList();

        state = state.copyWith(bookings: backendBookings);
      }
    } catch (_) {}
  }

  void addTestBooking(TestBooking booking) {
    final slotKey = '${booking.appointmentDate}_${booking.appointmentTime}';
    final currentCount = state.slotBookings[slotKey] ?? 0;
    final updatedSlots = Map<String, int>.from(state.slotBookings)..[slotKey] = currentCount + 1;

    // Create linked sample automatically
    final sampleId = 'ASTH-SMP-2026-${(state.samples.length + 452).toString().padLeft(5, '0')}';
    final newSample = SampleRecord(
      sampleId: sampleId,
      patientId: booking.patientId,
      bookingId: booking.bookingId,
      testName: booking.testName,
      sampleType: booking.sampleType,
      collectionDate: booking.appointmentDate,
      collectionTime: booking.appointmentTime,
      collectedBy: 'Unassigned',
      status: SampleStatus.samplePending,
      qrToken: 'SMP-TOKEN-$sampleId',
    );

    // Create linked invoice automatically
    final invoiceNo = 'ASTH-INV-2026-${(state.invoices.length + 126).toString().padLeft(5, '0')}';
    final newInvoice = InvoiceRecord(
      invoiceNumber: invoiceNo,
      bookingId: booking.bookingId,
      patientId: booking.patientId,
      patientName: booking.patientName,
      serviceName: booking.testName,
      price: booking.price,
      totalAmount: booking.price,
      status: PaymentStatus.pending,
      paymentDate: booking.appointmentDate,
    );

    final now = DateTime.now();
    final todayStr = DateFormat('dd-MM-yyyy').format(now);
    final timeStr = DateFormat('hh:mm a').format(now);

    // Create Notifications
    final newPatientNotice = AppNotification(
      id: 'n-${now.millisecondsSinceEpoch}-1',
      title: 'Appointment Confirmed',
      message: 'Your booking ${booking.bookingId} for ${booking.testName} is confirmed.',
      type: NotificationType.appointmentConfirmed,
      targetRole: UserRole.patient,
      targetUserId: booking.patientId,
      timestamp: now,
    );

    final newRecepNotice = AppNotification(
      id: 'n-${now.millisecondsSinceEpoch}-2',
      title: 'New Patient Booking',
      message: '${booking.patientName} booked ${booking.testName} (${booking.bookingId}).',
      type: NotificationType.newTestBooking,
      targetRole: UserRole.receptionist,
      timestamp: now,
    );

    // Audit Log
    final newAudit = AuditLogItem(
      logId: 'log-${now.millisecondsSinceEpoch}',
      userId: booking.patientId,
      userName: booking.patientName,
      role: UserRole.patient,
      action: 'Booked ${booking.testName} (${booking.bookingId})',
      entityId: booking.bookingId,
      date: todayStr,
      time: timeStr,
    );

    state = state.copyWith(
      bookings: [booking, ...state.bookings],
      samples: [newSample, ...state.samples],
      invoices: [newInvoice, ...state.invoices],
      slotBookings: updatedSlots,
      notifications: [newPatientNotice, newRecepNotice, ...state.notifications],
      auditLogs: [newAudit, ...state.auditLogs],
    );
  }

  // ── SAMPLE ACTIONS ────────────────────────────────────────────────────────

  void updateSampleStatus(String sampleId, SampleStatus newStatus, {String? collectedBy}) {
    final now = DateTime.now();
    final todayStr = DateFormat('dd-MM-yyyy').format(now);
    final timeStr = DateFormat('hh:mm a').format(now);

    final updatedSamples = state.samples.map((s) {
      if (s.sampleId == sampleId) {
        return s.copyWith(
          status: newStatus,
          collectedBy: collectedBy ?? s.collectedBy,
        );
      }
      return s;
    }).toList();

    // Update booking stage if needed
    final sample = state.samples.firstWhere((s) => s.sampleId == sampleId, orElse: () => state.samples.first);
    final updatedBookings = state.bookings.map((b) {
      if (b.bookingId == sample.bookingId) {
        if (newStatus == SampleStatus.sampleCollected) {
          return TestBooking(
            testId: b.testId,
            testName: b.testName,
            category: b.category,
            description: b.description,
            sampleType: b.sampleType,
            price: b.price,
            bookingId: b.bookingId,
            patientId: b.patientId,
            patientName: b.patientName,
            appointmentDate: b.appointmentDate,
            appointmentTime: b.appointmentTime,
            bookingStatus: 'SAMPLE COLLECTED',
            sampleStatus: 'Sample Collected',
            sampleCollectionDate: todayStr,
            sampleCollectionTime: timeStr,
            reportStatus: 'In Lab',
            currentStage: TestStage.sampleCollected,
          );
        } else if (newStatus == SampleStatus.processing) {
          return TestBooking(
            testId: b.testId,
            testName: b.testName,
            category: b.category,
            description: b.description,
            sampleType: b.sampleType,
            price: b.price,
            bookingId: b.bookingId,
            patientId: b.patientId,
            patientName: b.patientName,
            appointmentDate: b.appointmentDate,
            appointmentTime: b.appointmentTime,
            bookingStatus: 'PROCESSING',
            sampleStatus: 'Processing in Lab',
            sampleCollectionDate: b.sampleCollectionDate,
            sampleCollectionTime: b.sampleCollectionTime,
            reportStatus: 'Processing Results',
            currentStage: TestStage.processing,
          );
        }
      }
      return b;
    }).toList();

    // Audit log
    final newAudit = AuditLogItem(
      logId: 'log-${now.millisecondsSinceEpoch}',
      userId: 'staff',
      userName: collectedBy ?? 'Staff Member',
      role: UserRole.labTechnician,
      action: 'Updated Sample $sampleId status to ${newStatus.displayName}',
      entityId: sampleId,
      date: todayStr,
      time: timeStr,
    );

    // Patient Notification
    final notice = AppNotification(
      id: 'n-${now.millisecondsSinceEpoch}',
      title: 'Sample Updated',
      message: 'Sample $sampleId for ${sample.testName} is now ${newStatus.displayName}.',
      type: newStatus == SampleStatus.sampleCollected
          ? NotificationType.sampleCollected
          : NotificationType.sampleProcessing,
      targetRole: UserRole.patient,
      targetUserId: sample.patientId,
      timestamp: now,
    );

    state = state.copyWith(
      samples: updatedSamples,
      bookings: updatedBookings,
      notifications: [notice, ...state.notifications],
      auditLogs: [newAudit, ...state.auditLogs],
    );
  }

  // ── REPORT WORKFLOW (DRAFT -> VERIFICATION -> APPROVE) ───────────────────

  void submitReportDraft(LabReport report) {
    final now = DateTime.now();
    final todayStr = DateFormat('dd-MM-yyyy').format(now);
    final timeStr = DateFormat('hh:mm a').format(now);

    final existingIndex = state.reports.indexWhere((r) => r.reportId == report.reportId);
    List<LabReport> updatedReports;
    if (existingIndex >= 0) {
      updatedReports = List<LabReport>.from(state.reports)..[existingIndex] = report;
    } else {
      updatedReports = [report, ...state.reports];
    }

    // Admin Notification
    final adminNotice = AppNotification(
      id: 'n-${now.millisecondsSinceEpoch}',
      title: 'Report Verification Required',
      message: 'Report ${report.reportId} for ${report.patientName} (${report.testName}) is pending verification.',
      type: NotificationType.reportPendingVerification,
      targetRole: UserRole.admin,
      timestamp: now,
    );

    // Audit Log
    final audit = AuditLogItem(
      logId: 'log-${now.millisecondsSinceEpoch}',
      userId: 'staff',
      userName: 'Lab Tech / Receptionist',
      role: UserRole.labTechnician,
      action: 'Submitted Report Draft ${report.reportId} for verification',
      entityId: report.reportId,
      date: todayStr,
      time: timeStr,
    );

    state = state.copyWith(
      reports: updatedReports,
      notifications: [adminNotice, ...state.notifications],
      auditLogs: [audit, ...state.auditLogs],
    );
  }

  void approveReport(String reportId, String approvedByName) {
    final now = DateTime.now();
    final todayStr = DateFormat('dd-MM-yyyy').format(now);
    final timeStr = DateFormat('hh:mm a').format(now);

    final targetReport = state.reports.firstWhere((r) => r.reportId == reportId);
    final approvedReport = targetReport.copyWith(
      status: ReportStatus.approved,
      approvedBy: approvedByName,
      approvedAt: '$todayStr $timeStr',
    );

    final updatedReports = state.reports.map((r) => r.reportId == reportId ? approvedReport : r).toList();

    // Update TestBooking status to REPORT READY
    final updatedBookings = state.bookings.map((b) {
      if (b.bookingId == approvedReport.bookingId) {
        return TestBooking(
          testId: b.testId,
          testName: b.testName,
          category: b.category,
          description: b.description,
          sampleType: b.sampleType,
          price: b.price,
          bookingId: b.bookingId,
          patientId: b.patientId,
          patientName: b.patientName,
          appointmentDate: b.appointmentDate,
          appointmentTime: b.appointmentTime,
          bookingStatus: 'REPORT READY',
          sampleStatus: 'Completed',
          sampleCollectionDate: b.sampleCollectionDate,
          sampleCollectionTime: b.sampleCollectionTime,
          reportStatus: 'Report Generated & Ready for Download',
          reportDate: '$todayStr $timeStr',
          currentStage: TestStage.reportReady,
        );
      }
      return b;
    }).toList();

    // Patient Notification
    final patientNotice = AppNotification(
      id: 'n-${now.millisecondsSinceEpoch}',
      title: 'Your Report is Ready! 📄',
      message: 'Final report for ${approvedReport.testName} (${approvedReport.reportId}) is available for view and download.',
      type: NotificationType.reportReady,
      targetRole: UserRole.patient,
      targetUserId: approvedReport.patientId,
      timestamp: now,
    );

    // Audit Log
    final audit = AuditLogItem(
      logId: 'log-${now.millisecondsSinceEpoch}',
      userId: 'admin-001',
      userName: approvedByName,
      role: UserRole.admin,
      action: 'Approved Final Report $reportId',
      entityId: reportId,
      date: todayStr,
      time: timeStr,
    );

    state = state.copyWith(
      reports: updatedReports,
      bookings: updatedBookings,
      notifications: [patientNotice, ...state.notifications],
      auditLogs: [audit, ...state.auditLogs],
    );
  }

  void rejectReport(String reportId, String reason) {
    final now = DateTime.now();
    final todayStr = DateFormat('dd-MM-yyyy').format(now);
    final timeStr = DateFormat('hh:mm a').format(now);

    final updatedReports = state.reports.map((r) {
      if (r.reportId == reportId) {
        return r.copyWith(
          status: ReportStatus.rejected,
          rejectionReason: reason,
        );
      }
      return r;
    }).toList();

    final audit = AuditLogItem(
      logId: 'log-${now.millisecondsSinceEpoch}',
      userId: 'admin-001',
      userName: 'Admin / Lab Owner',
      role: UserRole.admin,
      action: 'Rejected Report $reportId: $reason',
      entityId: reportId,
      date: todayStr,
      time: timeStr,
    );

    state = state.copyWith(
      reports: updatedReports,
      auditLogs: [audit, ...state.auditLogs],
    );
  }

  // ── FORMULA MANAGEMENT ACTIONS ────────────────────────────────────────────

  void addFormula(FormulaItem formula) {
    state = state.copyWith(formulas: [formula, ...state.formulas]);
  }

  void toggleFormulaActive(String formulaId) {
    final updated = state.formulas.map((f) {
      if (f.formulaId == formulaId) {
        return f.copyWith(isActive: !f.isActive);
      }
      return f;
    }).toList();
    state = state.copyWith(formulas: updated);
  }

  // ── INVOICE ACTIONS ───────────────────────────────────────────────────────

  void updateInvoiceStatus(String invoiceNumber, PaymentStatus newStatus) {
    final now = DateTime.now();
    final todayStr = DateFormat('dd-MM-yyyy').format(now);
    final timeStr = DateFormat('hh:mm a').format(now);

    final updatedInvoices = state.invoices.map((inv) {
      if (inv.invoiceNumber == invoiceNumber) {
        return inv.copyWith(status: newStatus);
      }
      return inv;
    }).toList();

    final inv = state.invoices.firstWhere((i) => i.invoiceNumber == invoiceNumber);

    final audit = AuditLogItem(
      logId: 'log-${now.millisecondsSinceEpoch}',
      userId: 'staff',
      userName: 'Receptionist',
      role: UserRole.receptionist,
      action: 'Updated Invoice $invoiceNumber payment status to ${newStatus.displayName}',
      entityId: invoiceNumber,
      date: todayStr,
      time: timeStr,
    );

    final notice = AppNotification(
      id: 'n-${now.millisecondsSinceEpoch}',
      title: 'Invoice Payment Updated',
      message: 'Invoice $invoiceNumber payment status is now ${newStatus.displayName}.',
      type: NotificationType.paymentUpdate,
      targetRole: UserRole.patient,
      targetUserId: inv.patientId,
      timestamp: now,
    );

    state = state.copyWith(
      invoices: updatedInvoices,
      auditLogs: [audit, ...state.auditLogs],
      notifications: [notice, ...state.notifications],
    );
  }

  // ── DOCTOR CONSULTATION & TEST RECOMMENDATION ─────────────────────────────

  void addDoctorRecommendation({
    required String patientId,
    required String testName,
    required String doctorName,
  }) {
    final now = DateTime.now();
    final todayStr = DateFormat('dd-MM-yyyy').format(now);
    final timeStr = DateFormat('hh:mm a').format(now);

    final rec = {
      'id': 'rec-${now.millisecondsSinceEpoch}',
      'patientId': patientId,
      'testName': testName,
      'doctorName': doctorName,
      'date': todayStr,
    };

    final audit = AuditLogItem(
      logId: 'log-${now.millisecondsSinceEpoch}',
      userId: 'doc-001',
      userName: doctorName,
      role: UserRole.doctor,
      action: 'Recommended $testName test for patient $patientId',
      entityId: patientId,
      date: todayStr,
      time: timeStr,
    );

    final notice = AppNotification(
      id: 'n-${now.millisecondsSinceEpoch}',
      title: 'New Test Recommended by $doctorName',
      message: 'Dr. $doctorName recommended you take the $testName diagnostic test.',
      type: NotificationType.newTestBooking,
      targetRole: UserRole.patient,
      targetUserId: patientId,
      timestamp: now,
    );

    state = state.copyWith(
      recommendedTests: [rec, ...state.recommendedTests],
      auditLogs: [audit, ...state.auditLogs],
      notifications: [notice, ...state.notifications],
    );
  }

  // ── NOTIFICATION READ ACTIONS ─────────────────────────────────────────────

  void markNotificationAsRead(String notificationId) {
    final updated = state.notifications.map((n) {
      if (n.id == notificationId) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();
    state = state.copyWith(notifications: updated);
  }

  void markAllNotificationsAsRead(UserRole role, {String? userId}) {
    final updated = state.notifications.map((n) {
      if (n.targetRole == role && (userId == null || n.targetUserId == userId || n.targetUserId == null)) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();
    state = state.copyWith(notifications: updated);
  }

  // ── AUDIT LOG ACTION ──────────────────────────────────────────────────────

  void logAction({
    required String userId,
    required String userName,
    required UserRole role,
    required String action,
    required String entityId,
  }) {
    final now = DateTime.now();
    final todayStr = DateFormat('dd-MM-yyyy').format(now);
    final timeStr = DateFormat('hh:mm a').format(now);

    final audit = AuditLogItem(
      logId: 'log-${now.millisecondsSinceEpoch}',
      userId: userId,
      userName: userName,
      role: role,
      action: action,
      entityId: entityId,
      date: todayStr,
      time: timeStr,
    );

    state = state.copyWith(auditLogs: [audit, ...state.auditLogs]);
  }
}
