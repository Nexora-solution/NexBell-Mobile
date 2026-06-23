class PreRegisteredVisitEntity {
  final int id;
  final int residentId;
  final String visitorName;
  final String visitorDocument;
  final DateTime expectedAt;
  final bool active;

  PreRegisteredVisitEntity({
    required this.id,
    required this.residentId,
    required this.visitorName,
    required this.visitorDocument,
    required this.expectedAt,
    required this.active,
  });
}
