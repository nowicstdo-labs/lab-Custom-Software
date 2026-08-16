import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../features/auth/auth_provider.dart';
import '../../../models/app_notification.dart';
import '../../auth/auth_models.dart';
import '../../../services/shared_data_repository.dart';

class NotificationCenterScreen extends ConsumerWidget {
  const NotificationCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final currentRole = user?.role ?? UserRole.patient;

    final sharedData = ref.watch(sharedDataProvider);
    final notifications = sharedData.notifications.where((n) {
      return n.targetRole == currentRole || n.targetUserId == user?.id || n.targetUserId == 'ASTH-P-000125';
    }).toList();

    final unreadCount = notifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Notification Center'),
            if (unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$unreadCount New',
                  style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(sharedDataProvider.notifier).markAllNotificationsAsRead(currentRole, userId: user?.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All notifications marked as read.')),
              );
            },
            child: const Text('Mark All Read'),
          ),
        ],
      ),
      body: SafeArea(
        child: notifications.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.notifications_none, size: 64, color: AppColors.textSecondary),
                    SizedBox(height: 12),
                    Text('No notifications found.', style: TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: notifications.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = notifications[index];
                  return GestureDetector(
                    onTap: () {
                      ref.read(sharedDataProvider.notifier).markNotificationAsRead(item.id);
                      if (item.actionRoute != null) {
                        context.push(item.actionRoute!);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: item.isRead ? Colors.white : const Color(0xFFF0F9FF),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: item.isRead ? Colors.grey.shade200 : const Color(0xFF93C5FD),
                          width: item.isRead ? 1 : 1.5,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _typeColor(item.type).withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(_typeIcon(item.type), color: _typeColor(item.type), size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.title,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: item.isRead ? FontWeight.w600 : FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      DateFormat('hh:mm a').format(item.timestamp),
                                      style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.message,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: item.isRead ? AppColors.textSecondary : AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  IconData _typeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.appointmentConfirmed:
      case NotificationType.doctorAppointment:
        return Icons.event_available;
      case NotificationType.sampleCollected:
      case NotificationType.sampleProcessing:
        return Icons.science;
      case NotificationType.reportReady:
      case NotificationType.reportApproved:
      case NotificationType.reportAvailableDownload:
        return Icons.assignment_turned_in;
      case NotificationType.paymentUpdate:
        return Icons.receipt_long;
      default:
        return Icons.notifications;
    }
  }

  Color _typeColor(NotificationType type) {
    switch (type) {
      case NotificationType.appointmentConfirmed:
      case NotificationType.reportReady:
      case NotificationType.reportApproved:
        return const Color(0xFF2E7D32);
      case NotificationType.sampleCollected:
      case NotificationType.sampleProcessing:
        return const Color(0xFF1565C0);
      case NotificationType.paymentUpdate:
        return const Color(0xFF00796B);
      default:
        return AppColors.primary;
    }
  }
}
