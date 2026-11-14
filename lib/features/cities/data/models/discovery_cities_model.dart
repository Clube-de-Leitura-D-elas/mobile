import 'package:mobile/features/cities/domain/entities/discovery_cities_entity.dart';
import 'package:mobile/features/cities/domain/entities/discovery_city_entity.dart';

/// Resposta da `get-discovery-cities`:
/// `{ "reader_city_id", "cities": [{ "id", "name", "uf" }] }`.
class DiscoveryCitiesModel {
  final String readerCityId;
  final List<DiscoveryCityEntity> cities;

  const DiscoveryCitiesModel({
    required this.readerCityId,
    required this.cities,
  });

  factory DiscoveryCitiesModel.fromJson(Map<String, dynamic> json) {
    final cities = json['cities'] as List<dynamic>;
    return DiscoveryCitiesModel(
      readerCityId: json['reader_city_id'] as String,
      cities: [
        for (final city in cities.cast<Map<String, dynamic>>())
          DiscoveryCityEntity(
            id: city['id'] as String,
            name: city['name'] as String,
            uf: city['uf'] as String,
          ),
      ],
    );
  }

  DiscoveryCitiesEntity toDomain() =>
      DiscoveryCitiesEntity(readerCityId: readerCityId, cities: cities);
}
