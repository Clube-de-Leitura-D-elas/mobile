import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/groups/data/models/meeting_details_model.dart';
import 'package:mobile/features/groups/domain/entities/meeting_details_entity.dart';

const _fullJson = {
  'id': 'meeting-1',
  'number': 12,
  'date': '2026-08-22T22:00:00+00:00',
  'status': 'CONCLUDED',
  'description': 'Conversa sobre narrativa não confiável.',
  'cover_photo_url': 'https://example.com/cover.jpg',
  'book_title': 'Dom Casmurro',
  'book_cover_url': 'https://example.com/book.jpg',
  'host_name': 'Beatriz Souza',
  'location_name': 'Café Literário',
  'location_address': 'Rua das Flores, 12',
};

void main() {
  test('parses a complete Edge Function response', () {
    final model = MeetingDetailsModel.fromJson(_fullJson);

    expect(
      model.toDomain(),
      MeetingDetailsEntity(
        id: 'meeting-1',
        number: 12,
        date: DateTime.utc(2026, 8, 22, 22),
        bookTitle: 'Dom Casmurro',
        hostName: 'Beatriz Souza',
        locationName: 'Café Literário',
        locationAddress: 'Rua das Flores, 12',
        description: 'Conversa sobre narrativa não confiável.',
        coverPhotoUrl: 'https://example.com/cover.jpg',
      ),
    );
  });

  test('accepts null optional fields', () {
    final model = MeetingDetailsModel.fromJson(
      withFields({
        'number': null,
        'date': null,
        'description': null,
        'cover_photo_url': null,
        'location_name': null,
        'location_address': null,
      }),
    );

    expect(model.number, isNull);
    expect(model.date, isNull);
    expect(model.description, isNull);
    expect(model.coverPhotoUrl, isNull);
    expect(model.locationName, isNull);
    expect(model.locationAddress, isNull);
  });

  test('throws on a non-map response', () {
    expect(() => MeetingDetailsModel.fromJson(const []), throwsFormatException);
  });

  test('throws when required fields are missing or have the wrong type', () {
    expect(
      () => MeetingDetailsModel.fromJson(withFields({'book_title': null})),
      throwsFormatException,
    );
    expect(
      () => MeetingDetailsModel.fromJson(withFields({'number': '12'})),
      throwsFormatException,
    );
  });

  test('throws when the date is not ISO 8601', () {
    expect(
      () => MeetingDetailsModel.fromJson(withFields({'date': '22/08/2026'})),
      throwsFormatException,
    );
  });
}

Map<String, dynamic> withFields(Map<String, Object?> overrides) =>
    Map<String, dynamic>.of(_fullJson)..addAll(overrides);
