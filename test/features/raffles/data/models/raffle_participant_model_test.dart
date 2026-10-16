import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/raffles/data/models/raffle_participant_model.dart';

void main() {
  const tModel = RaffleParticipantModel(
    id: 'p1',
    name: 'Mariana de Souza',
    avatarUrl: null,
    hasAttended: true,
    isExcludedByRule: false,
    exclusionReason: null,
  );

  final tJson = {
    'id': 'p1',
    'name': 'Mariana de Souza',
    'avatar_url': null,
    'has_attended': true,
    'is_excluded_by_rule': false,
    'exclusion_reason': null,
  };

  group('RaffleParticipantModel', () {
    test('deve instanciar o modelo corretamente', () {
      expect(tModel.id, equals('p1'));
      expect(tModel.name, equals('Mariana de Souza'));
      expect(tModel.hasAttended, isTrue);
    });

    group('fromJson', () {
      test('deve retornar um modelo valido a partir do JSON', () {
        final result = RaffleParticipantModel.fromJson(tJson);
        expect(result.id, equals(tModel.id));
        expect(result.name, equals(tModel.name));
        expect(result.hasAttended, equals(tModel.hasAttended));
      });
    });

    group('toJson', () {
      test('deve retornar um Map JSON correto', () {
        final result = tModel.toJson();
        expect(result, equals(tJson));
      });
    });
  });
}
