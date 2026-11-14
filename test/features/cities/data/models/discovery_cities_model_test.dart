import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/cities/data/models/discovery_cities_model.dart';
import 'package:mobile/features/cities/domain/entities/discovery_cities_entity.dart';
import 'package:mobile/features/cities/domain/entities/discovery_city_entity.dart';

void main() {
  test('parses the reader city and the city list in order', () {
    final cities = DiscoveryCitiesModel.fromJson({
      'reader_city_id': 'c-2',
      'cities': [
        {'id': 'c-1', 'name': 'Canoas', 'uf': 'RS'},
        {'id': 'c-2', 'name': 'Porto Alegre', 'uf': 'RS'},
      ],
    }).toDomain();

    expect(
      cities,
      const DiscoveryCitiesEntity(
        readerCityId: 'c-2',
        cities: [
          DiscoveryCityEntity(id: 'c-1', name: 'Canoas', uf: 'RS'),
          DiscoveryCityEntity(id: 'c-2', name: 'Porto Alegre', uf: 'RS'),
        ],
      ),
    );
    expect(cities.readerCity?.name, 'Porto Alegre');
  });

  test('readerCity is null when the reader city is not listed', () {
    final cities = DiscoveryCitiesModel.fromJson({
      'reader_city_id': 'c-9',
      'cities': <dynamic>[],
    }).toDomain();

    expect(cities.readerCity, isNull);
  });

  test('throws without the reader city', () {
    expect(
      () => DiscoveryCitiesModel.fromJson({'cities': <dynamic>[]}),
      throwsA(isA<TypeError>()),
    );
  });
}
