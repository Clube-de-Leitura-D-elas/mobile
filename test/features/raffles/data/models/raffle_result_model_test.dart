import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/raffles/data/models/raffle_result_model.dart';
import 'package:mobile/features/raffles/domain/entities/raffle_result.dart';

void main() {
  final tDrawnAt = DateTime.parse('2026-10-21T18:00:00.000Z');

  final tRaffleResultModel = RaffleResultModel(
    meetingId: 'meeting-123',
    winnerId: 'winner-1',
    winnerName: 'Ana Beatriz',
    winnerAvatarUrl: 'https://example.com/avatar.jpg',
    bookTitle: 'O Pequeno Príncipe',
    bookAuthor: 'Antoine de Saint-Exupéry',
    bookCoverUrl: 'https://example.com/cover.jpg',
    drawnAt: tDrawnAt,
  );

  final tJson = {
    'meeting_id': 'meeting-123',
    'winner_id': 'winner-1',
    'winner_name': 'Ana Beatriz',
    'winner_avatar_url': 'https://example.com/avatar.jpg',
    'book_title': 'O Pequeno Príncipe',
    'book_author': 'Antoine de Saint-Exupéry',
    'book_cover_url': 'https://example.com/cover.jpg',
    'drawn_at': '2026-10-21T18:00:00.000Z',
  };

  test('RaffleResultModel deve instanciar e converter para domínio corretamente', () {
    final domain = tRaffleResultModel.toDomain();

    expect(domain, isA<RaffleResult>());
    expect(domain.meetingId, 'meeting-123');
    expect(domain.winnerId, 'winner-1');
    expect(domain.winnerName, 'Ana Beatriz');
    expect(domain.bookTitle, 'O Pequeno Príncipe');
    expect(domain.bookAuthor, 'Antoine de Saint-Exupéry');
    expect(domain.drawnAt, tDrawnAt);
  });

  test('fromJson deve desserializar JSON corretamente', () {
    final result = RaffleResultModel.fromJson(tJson);

    expect(result.meetingId, 'meeting-123');
    expect(result.winnerId, 'winner-1');
    expect(result.winnerName, 'Ana Beatriz');
    expect(result.bookTitle, 'O Pequeno Príncipe');
    expect(result.drawnAt, tDrawnAt);
  });

  test('fromJson deve suportar campos alternativos participant_id e participant_name', () {
    final altJson = {
      'meeting_id': 'meeting-123',
      'participant_id': 'p-99',
      'participant_name': 'Mariana',
      'avatar_url': 'https://avatar.png',
      'book_title': 'Capitães da Areia',
    };

    final result = RaffleResultModel.fromJson(altJson);
    expect(result.winnerId, 'p-99');
    expect(result.winnerName, 'Mariana');
    expect(result.winnerAvatarUrl, 'https://avatar.png');
    expect(result.bookTitle, 'Capitães da Areia');
  });

  test('toJson deve serializar para Map corretamente', () {
    final json = tRaffleResultModel.toJson();

    expect(json['meeting_id'], 'meeting-123');
    expect(json['winner_id'], 'winner-1');
    expect(json['winner_name'], 'Ana Beatriz');
    expect(json['book_title'], 'O Pequeno Príncipe');
    expect(json['drawn_at'], '2026-10-21T18:00:00.000Z');
  });
}
