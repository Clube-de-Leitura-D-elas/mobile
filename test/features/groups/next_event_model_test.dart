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

  // ── toDomain ─────────────────────────────────────────────────────────────

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
