import '../features/auth/auth_models.dart';

class AuditLogItem {
  final String logId;
  final String userId;
  final String userName;
  final UserRole role;
  final String action;
  final String entityId;
  final String date;
  final String time;

  const AuditLogItem({
    required this.logId,
    required this.userId,
    required this.userName,
    required this.role,
    required this.action,
    required this.entityId,
    required this.date,
    required this.time,
  });
}
