import 'dart:convert';
import '../../../common/utils/api_client.dart';

/// A building option for the credential-request autocomplete.
class BuildingOption {
  final int id;
  final String name;
  final String district;

  BuildingOption({required this.id, required this.name, required this.district});

  factory BuildingOption.fromJson(Map<String, dynamic> json) => BuildingOption(
        id: (json['id'] as num).toInt(),
        name: (json['name'] ?? '') as String,
        district: (json['district'] ?? '') as String,
      );
}

/// An apartment of a building. [claimable] is true while the apartment is still
/// pending (its resident never activated it on first login).
class ApartmentOption {
  final String code;
  final bool claimable;

  ApartmentOption({required this.code, required this.claimable});

  factory ApartmentOption.fromJson(Map<String, dynamic> json) => ApartmentOption(
        code: (json['code'] ?? '') as String,
        claimable: (json['claimable'] ?? false) as bool,
      );
}

/// Outcome of a resident credential claim.
class ClaimResult {
  final bool sent;
  final String message;

  ClaimResult({required this.sent, required this.message});
}

/// Public onboarding endpoints (no auth required) used by the credential-request
/// flow before the resident has any credentials.
class OnboardingApi {
  static Future<List<BuildingOption>> fetchBuildings() async {
    final res = await ApiClient.get('/api/onboarding/buildings');
    if (res.statusCode != 200) {
      throw Exception('No se pudo cargar la lista de edificios.');
    }
    final list = jsonDecode(res.body) as List<dynamic>;
    return list
        .map((e) => BuildingOption.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<List<ApartmentOption>> fetchApartments(int buildingId) async {
    final res = await ApiClient.get('/api/onboarding/buildings/$buildingId/apartments');
    if (res.statusCode != 200) {
      throw Exception('No se pudieron cargar los departamentos.');
    }
    final list = jsonDecode(res.body) as List<dynamic>;
    return list
        .map((e) => ApartmentOption.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<ClaimResult> claimResident({
    required String buildingName,
    required String apartmentCode,
    required String personalEmail,
  }) async {
    final res = await ApiClient.post(
      '/api/onboarding/credentials/claim-resident',
      body: {
        'buildingName': buildingName,
        'apartmentCode': apartmentCode,
        'personalEmail': personalEmail,
      },
    );
    Map<String, dynamic> data;
    try {
      data = jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      data = {};
    }
    final sent = (data['sent'] ?? (res.statusCode == 200)) as bool;
    final message = (data['message'] ??
            'No se pudo procesar la solicitud. Inténtalo de nuevo.') as String;
    return ClaimResult(sent: sent, message: message);
  }
}
