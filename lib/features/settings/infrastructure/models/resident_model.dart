import '../../domain/entities/resident_entity.dart';

class ResidentModel extends ResidentEntity {
  ResidentModel({
    required super.id,
    required super.userId,
    required super.fullName,
    required super.documentNumber,
    required super.email,
    required super.phone,
  });

  factory ResidentModel.fromJson(Map<String, dynamic> json) {
    return ResidentModel(
      id: json['id'],
      userId: json['userId'],
      fullName: json['fullName'],
      documentNumber: json['documentNumber'],
      email: json['email'],
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'fullName': fullName,
      'documentNumber': documentNumber,
      'email': email,
      'phone': phone,
    };
  }
}
