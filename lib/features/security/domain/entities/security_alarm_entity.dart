class SecurityAlarmEntity {
  final int id;
  final String sensorType;
  final String status;
  final DateTime triggeredAt;

  SecurityAlarmEntity({
    required this.id,
    required this.sensorType,
    required this.status,
    required this.triggeredAt,
  });
}
