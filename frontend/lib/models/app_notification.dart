import '../features/auth/auth_models.dart';

enum NotificationType {
  appointmentConfirmed,
  appointmentReminder,
  appointmentChanged,
  sampleCollected,
  sampleProcessing,
  reportReady,
  reportApproved,
  reportAvailableDownload,
  paymentUpdate,
  newPatientBooking,
  newTestBooking,
  doctorAppointment,
  reportPending,
  newSampleAssigned,
  reportSubmissionRequired,
  newStaffAccount,
  reportPendingVerification,
  reportSubmitted,
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final UserRole targetRole;
  final String? targetUserId;
  final DateTime timestamp;
  final bool isRead;
  final String? actionRoute;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.targetRole,
    this.targetUserId,
    required this.timestamp,
    this.isRead = false,
    this.actionRoute,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    UserRole? targetRole,
    String? targetUserId,
    DateTime? timestamp,
    bool? isRead,
    String? actionRoute,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      targetRole: targetRole ?? this.targetRole,
      targetUserId: targetUserId ?? this.targetUserId,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      actionRoute: actionRoute ?? this.actionRoute,
    );
  }
}
