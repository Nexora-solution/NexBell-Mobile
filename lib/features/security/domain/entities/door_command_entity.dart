class DoorCommandEntity {
  final int id;
  final String commandType;
  final String status;
  final DateTime dispatchedAt;
  final DateTime? confirmedAt;

  DoorCommandEntity({
    required this.id,
    required this.commandType,
    required this.status,
    required this.dispatchedAt,
    this.confirmedAt,
  });
}
