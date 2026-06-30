class VisitRequestEntity {
  final int id;
  final String visitorName;
  final int apartmentId;
  final String status;
  final String? photoUrl;
  final String? audioUrl;
  final DateTime createdAt;

  VisitRequestEntity({
    required this.id,
    required this.visitorName,
    required this.apartmentId,
    required this.status,
    this.photoUrl,
    this.audioUrl,
    required this.createdAt,
  });
}
