class IntercomNotificationEntity {
  final int id;
  final String status;
  final DateTime sentAt;
  final bool isRead;

  IntercomNotificationEntity({
    required this.id,
    required this.status,
    required this.sentAt,
    required this.isRead,
  });
}
