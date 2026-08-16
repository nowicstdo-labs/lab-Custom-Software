class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String timestamp;
  final bool unread;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.unread = false,
  });
}
