class ApartmentEntity {
  final int id;
  final int buildingId;
  final String code;
  final int? residentId;

  ApartmentEntity({
    required this.id,
    required this.buildingId,
    required this.code,
    this.residentId,
  });
}
