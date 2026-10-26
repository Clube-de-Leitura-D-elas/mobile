import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/raffles/data/models/raffle_participant_model.dart';
import 'package:mobile/features/raffles/domain/entities/raffle_participant.dart';

void main() {
  const tModel = RaffleParticipantModel(
    id: 'p1',
    name: 'Mariana de Souza',
    avatarUrl: null,
    hasAttended: true,
    isExcludedByRule: false,
    exclusionReason: null,
    bookTitle: 'Dom Casmurro',
    bookAuthor: 'Machado de Assis',
    bookCoverUrl: 'https://cover.jpg',
  );

  final tJson = {
    'id': 'p1',
    'name': 'Mariana de Souza',
    'avatar_url': null,
    'has_attended': true,
    'is_excluded_by_rule': false,
    'exclusion_reason': null,
    'book_title': 'Dom Casmurro',
    'book_author': 'Machado de Assis',
    'book_cover_url': 'https://cover.jpg',
  };

  group('RaffleParticipantModel', () {
    test('deve instanciar o modelo corretamente', () {
      expect(tModel.id, equals('p1'));
      expect(tModel.name, equals('Mariana de Souza'));
      expect(tModel.hasAttended, isTrue);
      expect(tModel.bookTitle, equals('Dom Casmurro'));
    });

    group('fromJson', () {
      test('deve retornar um modelo valido a partir do JSON', () {
        final result = RaffleParticipantModel.fromJson(tJson);
        expect(result.id, equals(tModel.id));
        expect(result.name, equals(tModel.name));
        expect(result.hasAttended, equals(tModel.hasAttended));
        expect(result.bookTitle, equals('Dom Casmurro'));
      });
    });

    group('toJson', () {
      test('deve retornar um Map JSON correto', () {
        final result = tModel.toJson();
        expect(result, equals(tJson));
      });
    });

    test('toDomain deve converter para RaffleParticipant com dados do livro', () {
      final domain = tModel.toDomain();
      expect(domain, isA<RaffleParticipant>());
      expect(domain.bookTitle, equals('Dom Casmurro'));
      expect(domain.bookAuthor, equals('Machado de Assis'));
      expect(domain.isSelected, isTrue);
    });
  });
}
