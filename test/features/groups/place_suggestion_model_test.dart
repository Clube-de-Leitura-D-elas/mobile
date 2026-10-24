import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/groups/data/models/place_suggestion_model.dart';
import 'package:mobile/features/groups/domain/entities/place_suggestion_entity.dart';

void main() {
  group('PlaceSuggestionModel', () {
    test('given the search response, when parsed, then maps each place', () {
      final places = PlaceSuggestionModel.listFromEnvelope(const {
        'places': [
          {
            'google_place_id': 'place-1',
            'name': 'Café Paris',
            'address': 'R. A, 10 - Centro, Porto Alegre - RS, 90010-273',
          },
        ],
      });

      expect(places.map((place) => place.toDomain()), const [
        PlaceSuggestionEntity(
          googlePlaceId: 'place-1',
          name: 'Café Paris',
          address: 'R. A, 10 - Centro, Porto Alegre - RS, 90010-273',
        ),
      ]);
    });

    test('given no places, when parsed, then returns an empty list', () {
      expect(
        PlaceSuggestionModel.listFromEnvelope(const {'places': []}),
        isEmpty,
      );
    });

    test('given an invalid response, when parsed, then throws', () {
      expect(
        () => PlaceSuggestionModel.listFromEnvelope(const {'places': null}),
        throwsFormatException,
      );
      expect(
        () => PlaceSuggestionModel.listFromEnvelope(const {
          'places': [
            {'google_place_id': 'place-1', 'name': 'Café Paris'},
          ],
        }),
        throwsFormatException,
      );
    });
  });

  group('PlaceSuggestionEntity', () {
    test('given an address with CEP, when shortened, then drops the CEP', () {
      const place = PlaceSuggestionEntity(
        googlePlaceId: 'place-1',
        name: 'Café Paris',
        address: 'R. A, 10 - Centro, Porto Alegre - RS, 90010-273',
      );

      expect(place.shortAddress, 'R. A, 10 - Centro, Porto Alegre - RS');
      expect(place.label, 'Café Paris - R. A, 10 - Centro, Porto Alegre - RS');
    });

    test(
      'given a result that is only an address, when labelled, then does not repeat it',
      () {
        const place = PlaceSuggestionEntity(
          googlePlaceId: 'place-2',
          name: 'R. das Flores, 120',
          address: 'R. das Flores, 120 - Centro, Viamão - RS, 94400-000',
        );

        expect(place.label, 'R. das Flores, 120 - Centro, Viamão - RS');
      },
    );
  });
}
