class IntercomQueueItemEntity {
  final int id;
  final int visitRequestId;
  final int? assignedDoormanId;
  final DateTime enqueuedAt;
  final String status;
  final String visitorName;
  final String? dni;
  final String type;

  IntercomQueueItemEntity({
    required this.id,
    required this.visitRequestId,
    this.assignedDoormanId,
    required this.enqueuedAt,
    required this.status,
    required this.visitorName,
    this.dni,
    required this.type,
  });
}
