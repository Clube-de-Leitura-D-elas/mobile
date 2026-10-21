import 'package:mobile/features/groups/domain/entities/place_suggestion_entity.dart';

class PlaceSuggestionModel extends PlaceSuggestionEntity {
  const PlaceSuggestionModel({
    required super.googlePlaceId,
    required super.name,
    required super.address,
  });

  factory PlaceSuggestionModel.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) {
      throw const FormatException('Invalid place suggestion response.');
    }

    final googlePlaceId = json['google_place_id'];
    final name = json['name'];
    final address = json['address'];
    if (googlePlaceId is! String || name is! String || address is! String) {
      throw const FormatException('Invalid place suggestion response.');
    }

    return PlaceSuggestionModel(
      googlePlaceId: googlePlaceId,
      name: name,
      address: address,
    );
  }

  /// Lê a resposta de `search-places`: `{ "places": [ ... ] }`.
  static List<PlaceSuggestionModel> listFromEnvelope(dynamic json) {
    if (json is! Map<String, dynamic> || json['places'] is! List) {
      throw const FormatException('Invalid place suggestions response.');
    }

    return (json['places'] as List)
        .map(PlaceSuggestionModel.fromJson)
        .toList(growable: false);
  }

  PlaceSuggestionEntity toDomain() => PlaceSuggestionEntity(
    googlePlaceId: googlePlaceId,
    name: name,
    address: address,
  );
}
