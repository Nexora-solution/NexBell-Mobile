class AccessRecordEntity {
  final int id;
  final String correlationId;
  final String decision;
  final bool isSealed;
  final List<String> timeline;
  final DateTime createdAt;

  AccessRecordEntity({
    required this.id,
    required this.correlationId,
    required this.decision,
    required this.isSealed,
    required this.timeline,
    required this.createdAt,
  });
}
