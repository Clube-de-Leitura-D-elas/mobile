import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/groups/data/models/next_event_model.dart';
import 'package:mobile/features/groups/domain/entities/next_event_entity.dart';

void main() {
  const validInnerJson = {
    'location_name': 'Porto Alegre, RS',
    'date': '2026-09-15T21:30:00Z',
    'host_name': 'Roberta',
  };

  const validEnvelope = {'next_event': validInnerJson};

  // ── fromEnvelope ──────────────────────────────────────────────────────────

  test('fromEnvelope maps all fields from the next_event wrapper', () {
    final model = NextEventModel.fromEnvelope(validEnvelope);

    expect(model, isNotNull);
    expect(model!.location, 'Porto Alegre, RS');
    expect(model.date, DateTime.utc(2026, 9, 15, 21, 30));
    expect(model.hostName, 'Roberta');
  });

  test('fromEnvelope returns null when next_event is null', () {
    final model = NextEventModel.fromEnvelope({'next_event': null});
    expect(model, isNull);
  });

  test('fromEnvelope throws FormatException for non-map input', () {
    expect(
      () => NextEventModel.fromEnvelope('invalid'),
      throwsA(isA<FormatException>()),
    );
  });

  test('fromEnvelope uses empty string when location_name is null', () {
    final model = NextEventModel.fromEnvelope({
      'next_event': {
        'location_name': null,
        'date': '2026-09-15T21:30:00Z',
        'host_name': 'Roberta',
      },
    });
    expect(model!.location, '');
  });

  // ── fromJson ─────────────────────────────────────────────────────────────

  test('fromJson maps location_name, date and host_name correctly', () {
    final model = NextEventModel.fromJson(validInnerJson);

    expect(model.location, 'Porto Alegre, RS');
    expect(model.date, DateTime.utc(2026, 9, 15, 21, 30));
    expect(model.hostName, 'Roberta');
  });

  test('fromJson throws FormatException for non-map input', () {
    expect(
      () => NextEventModel.fromJson('invalid'),
      throwsA(isA<FormatException>()),
    );
  });

  test('fromJson throws FormatException when required fields are missing', () {
    expect(
      () => NextEventModel.fromJson(const {'location_name': 'Porto Alegre'}),
      throwsA(isA<FormatException>()),
    );
  });

  test('fromJson throws FormatException when field types are wrong', () {
    expect(
      () => NextEventModel.fromJson(const {
        'location_name': 'Porto Alegre, RS',
        'date': 12345,
        'host_name': 'Roberta',
      }),
      throwsA(isA<FormatException>()),
    );
  });

  test('fromJson throws FormatException when date is not ISO 8601', () {
    expect(
      () => NextEventModel.fromJson(const {
        'location_name': 'Porto Alegre, RS',
        'date': 'not-a-date',
        'host_name': 'Roberta',
      }),
      throwsA(isA<FormatException>()),
    );
  });

  test('Given a next event with a book and cover, '
      'When parsing from JSON, '
      'Then bookTitle and bookCoverUrl are mapped', () {
    final model = NextEventModel.fromJson(const {
      ...validInnerJson,
      'book_title': 'Ponciá Vicêncio',
      'book_cover_url': 'https://example.com/cover.jpg',
    });

    expect(model.bookTitle, 'Ponciá Vicêncio');
    expect(model.bookCoverUrl, 'https://example.com/cover.jpg');
  });

  test('Given a next event without book fields, '
      'When parsing from JSON, '
      'Then bookTitle and bookCoverUrl are null', () {
    final model = NextEventModel.fromJson(validInnerJson);

    expect(model.bookTitle, isNull);
    expect(model.bookCoverUrl, isNull);
  });

  test('Given a next event whose book has no cover, '
      'When parsing from JSON, '
      'Then bookTitle is mapped and bookCoverUrl is null', () {
    final model = NextEventModel.fromJson(const {
      ...validInnerJson,
      'book_title': "Olhos d'água",
      'book_cover_url': null,
    });

    expect(model.bookTitle, "Olhos d'água");
    expect(model.bookCoverUrl, isNull);
  });

  test('Given a non-string book_title, '
      'When parsing from JSON, '
      'Then a FormatException is thrown', () {
    expect(
      () =>
          NextEventModel.fromJson(const {...validInnerJson, 'book_title': 42}),
      throwsA(isA<FormatException>()),
    );
  });

  test('Given a non-string book_cover_url, '
      'When parsing from JSON, '
      'Then a FormatException is thrown', () {
    expect(
      () => NextEventModel.fromJson(const {
        ...validInnerJson,
        'book_title': 'Ponciá Vicêncio',
        'book_cover_url': {'url': 'https://example.com/cover.jpg'},
      }),
      throwsA(isA<FormatException>()),
    );
  });

  // ── toDomain ─────────────────────────────────────────────────────────────

  test('Given a model with book data, '
      'When converting to domain, '
      'Then the entity keeps bookTitle and bookCoverUrl', () {
    final model = NextEventModel.fromJson(const {
      ...validInnerJson,
      'book_title': 'Ponciá Vicêncio',
      'book_cover_url': 'https://example.com/cover.jpg',
    });

    expect(
      model.toDomain(),
      NextEventEntity(
        location: 'Porto Alegre, RS',
        date: DateTime.utc(2026, 9, 15, 21, 30),
        hostName: 'Roberta',
        bookTitle: 'Ponciá Vicêncio',
        bookCoverUrl: 'https://example.com/cover.jpg',
      ),
    );
  });

  test('toDomain returns a NextEventEntity with the same values', () {
    final model = NextEventModel.fromJson(validInnerJson);
    final entity = model.toDomain();

    expect(
      entity,
      NextEventEntity(
        location: 'Porto Alegre, RS',
        date: DateTime.utc(2026, 9, 15, 21, 30),
        hostName: 'Roberta',
      ),
    );
  });
}
