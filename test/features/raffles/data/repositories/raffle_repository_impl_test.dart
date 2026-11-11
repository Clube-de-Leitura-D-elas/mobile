import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/supabase/supabase_failure.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/raffles/data/datasources/raffle_remote_data_source.dart';
import 'package:mobile/features/raffles/data/models/raffle_participant_model.dart';
import 'package:mobile/features/raffles/data/models/raffle_result_model.dart';
import 'package:mobile/features/raffles/data/repositories/raffle_repository_impl.dart';
import 'package:mobile/features/raffles/domain/entities/raffle_failure.dart';
import 'package:mobile/features/raffles/domain/entities/raffle_participant.dart';
import 'package:mobile/features/raffles/domain/entities/raffle_result.dart';
import 'package:mocktail/mocktail.dart';

class MockRaffleRemoteDataSource extends Mock
    implements RaffleRemoteDataSource {}

void main() {
  late RaffleRepositoryImpl repository;
  late MockRaffleRemoteDataSource mockDataSource;

  setUpAll(() {
    registerFallbackValue(
      const RaffleResultModel(
        meetingId: 'm1',
        winnerId: 'p1',
        winnerName: 'Beatriz',
        bookTitle: '1984',
      ),
    );
  });

  setUp(() {
    mockDataSource = MockRaffleRemoteDataSource();
    repository = RaffleRepositoryImpl(remoteDataSource: mockDataSource);
  });

  group('getEligibleParticipants', () {
    const tMeetingId = 'm1';
    const tModel = RaffleParticipantModel(
      id: 'p1',
      name: 'Mariana de Souza',
      avatarUrl: null,
      hasAttended: true,
      isExcludedByRule: false,
    );

    test(
      'deve chamar o data source e retornar a lista de participantes com sucesso',
      () async {
        when(
          () => mockDataSource.getEligibleParticipants(tMeetingId),
        ).thenAnswer((_) async => [tModel]);

        final result = await repository.getEligibleParticipants(tMeetingId);

        expect(result, isA<Success<List<RaffleParticipant>, RaffleFailure>>());
        final participants =
            (result as Success<List<RaffleParticipant>, RaffleFailure>).data;
        expect(participants.length, equals(1));
        expect(participants.first.id, equals('p1'));
        expect(participants.first.name, equals('Mariana de Souza'));

        verify(
          () => mockDataSource.getEligibleParticipants(tMeetingId),
        ).called(1);
        verifyNoMoreInteractions(mockDataSource);
      },
    );

    test(
      'deve retornar Failure com RaffleFailure quando o data source lançar uma exceção',
      () async {
        when(
          () => mockDataSource.getEligibleParticipants(tMeetingId),
        ).thenThrow(Exception('Erro no servidor'));

        final result = await repository.getEligibleParticipants(tMeetingId);

        expect(result, isA<Failure<List<RaffleParticipant>, RaffleFailure>>());
        verify(
          () => mockDataSource.getEligibleParticipants(tMeetingId),
        ).called(1);
        verifyNoMoreInteractions(mockDataSource);
      },
    );
  });

  group('confirmRaffle', () {
    const tMeetingId = 'm1';
    const tSelectedIds = ['p1', 'p2'];

    test('deve chamar o data source e concluir com sucesso', () async {
      when(
        () => mockDataSource.confirmRaffle(tMeetingId, tSelectedIds),
      ).thenAnswer((_) async => Future.value());

      final result = await repository.confirmRaffle(
        meetingId: tMeetingId,
        selectedParticipantIds: tSelectedIds,
      );

      expect(result, isA<Success<void, RaffleFailure>>());
      verify(
        () => mockDataSource.confirmRaffle(tMeetingId, tSelectedIds),
      ).called(1);
      verifyNoMoreInteractions(mockDataSource);
    });

    test(
      'deve retornar Failure quando o data source lançar uma exceção ao confirmar',
      () async {
        when(
          () => mockDataSource.confirmRaffle(tMeetingId, tSelectedIds),
        ).thenThrow(Exception('Erro ao confirmar sorteio'));

        final result = await repository.confirmRaffle(
          meetingId: tMeetingId,
          selectedParticipantIds: tSelectedIds,
        );

        expect(result, isA<Failure<void, RaffleFailure>>());
        verify(
          () => mockDataSource.confirmRaffle(tMeetingId, tSelectedIds),
        ).called(1);
        verifyNoMoreInteractions(mockDataSource);
      },
    );
  });

  group('getRaffleResult', () {
    const tMeetingId = 'm1';
    const tModel = RaffleResultModel(
      meetingId: tMeetingId,
      winnerId: 'p1',
      winnerName: 'Beatriz',
      bookTitle: '1984',
    );

    test('deve retornar Success com RaffleResult quando houver resultado salvo', () async {
      when(
        () => mockDataSource.getRaffleResult(tMeetingId),
      ).thenAnswer((_) async => tModel);

      final result = await repository.getRaffleResult(tMeetingId);

      expect(result, isA<Success<RaffleResult?, RaffleFailure>>());
      final domain = (result as Success<RaffleResult?, RaffleFailure>).data;
      expect(domain?.winnerName, equals('Beatriz'));
      expect(domain?.bookTitle, equals('1984'));
    });

    test('deve retornar Failure quando o datasource lançar erro', () async {
      when(
        () => mockDataSource.getRaffleResult(tMeetingId),
      ).thenThrow(Exception('Erro no banco'));

      final result = await repository.getRaffleResult(tMeetingId);

      expect(result, isA<Failure<RaffleResult?, RaffleFailure>>());
    });
  });

  group('drawRaffle', () {
    const tMeetingId = 'm1';
    const tModel = RaffleResultModel(
      meetingId: tMeetingId,
      winnerId: 'p1',
      winnerName: 'Beatriz',
      bookTitle: '1984',
    );

    test('deve retornar Success com RaffleResult após sortear', () async {
      when(
        () => mockDataSource.drawRaffle(
          meetingId: tMeetingId,
          eligibleParticipantIds: ['p1'],
        ),
      ).thenAnswer((_) async => tModel);

      final result = await repository.drawRaffle(
        meetingId: tMeetingId,
        eligibleParticipantIds: ['p1'],
      );

      expect(result, isA<Success<RaffleResult, RaffleFailure>>());
      final domain = (result as Success<RaffleResult, RaffleFailure>).data;
      expect(domain.winnerName, equals('Beatriz'));
    });

    test('deve retornar Failure quando datasource falhar ao sortear', () async {
      when(
        () => mockDataSource.drawRaffle(
          meetingId: tMeetingId,
          eligibleParticipantIds: ['p1'],
        ),
      ).thenThrow(Exception('Falha no sorteio'));

      final result = await repository.drawRaffle(
        meetingId: tMeetingId,
        eligibleParticipantIds: ['p1'],
      );

      expect(result, isA<Failure<RaffleResult, RaffleFailure>>());
    });
  });

  group('saveRaffleResult', () {
    const tResult = RaffleResult(
      meetingId: 'm1',
      winnerId: 'p1',
      winnerName: 'Beatriz',
      bookTitle: '1984',
    );

    test('deve salvar o resultado e retornar Success', () async {
      when(
        () => mockDataSource.saveRaffleResult(any()),
      ).thenAnswer((_) async => Future.value());

      final result = await repository.saveRaffleResult(tResult);

      expect(result, isA<Success<void, RaffleFailure>>());
    });

    test('deve retornar Failure quando datasource falhar ao salvar', () async {
      when(
        () => mockDataSource.saveRaffleResult(any()),
      ).thenThrow(Exception('Falha ao salvar'));

      final result = await repository.saveRaffleResult(tResult);

      expect(result, isA<Failure<void, RaffleFailure>>());
    });
  });

  group('failure mapping', () {
    RaffleRemoteException remote(
      SupabaseFailureKind kind, {
      String? code,
      String message = 'raw',
    }) => RaffleRemoteException(
      FunctionSupabaseFailure(message: message, code: code, kind: kind),
    );

    final cases = <String, (Object, RaffleFailure)>{
      'network': (
        remote(SupabaseFailureKind.network, code: '0'),
        const RaffleNetworkFailure(),
      ),
      '401': (
        remote(SupabaseFailureKind.unauthorized, code: '401'),
        const RaffleSessionExpiredFailure(),
      ),
      '409 already recorded': (
        remote(
          SupabaseFailureKind.conflict,
          code: '409',
          message: 'raffle already recorded for this meeting',
        ),
        const RaffleAlreadyRecordedFailure(),
      ),
      '403': (
        remote(SupabaseFailureKind.forbidden, code: '403'),
        const RaffleForbiddenFailure(),
      ),
      '409 meeting not ended': (
        remote(
          SupabaseFailureKind.conflict,
          code: '409',
          message: 'meeting record is only available after the meeting is ended',
        ),
        const RaffleMeetingNotEndedFailure(),
      ),
      '409 book already drawn': (
        remote(
          SupabaseFailureKind.conflict,
          code: '409',
          message: 'book already drawn in this group',
        ),
        const RaffleBookAlreadyDrawnFailure(),
      ),
      '409 book suggestion unavailable': (
        remote(
          SupabaseFailureKind.conflict,
          code: '409',
          message: 'book suggestion is no longer available',
        ),
        const RaffleBookSuggestionUnavailableFailure(),
      ),
      'unknown 409': (
        remote(SupabaseFailureKind.conflict, code: '409', message: 'other'),
        const RaffleServerFailure(),
      ),
      '422': (
        remote(SupabaseFailureKind.validation, code: '422'),
        const RaffleParticipantsChangedFailure(),
      ),
      '500': (
        remote(SupabaseFailureKind.server, code: '500'),
        const RaffleServerFailure(),
      ),
      'unexpected exception': (
        Exception('boom'),
        const RaffleServerFailure(),
      ),
    };

    for (final MapEntry(key: name, value: (error, expected)) in cases.entries) {
      test('maps $name', () async {
        when(
          () => mockDataSource.drawRaffle(
            meetingId: any(named: 'meetingId'),
            eligibleParticipantIds: any(named: 'eligibleParticipantIds'),
          ),
        ).thenThrow(error);

        final result = await repository.drawRaffle(
          meetingId: 'meeting-1',
          eligibleParticipantIds: const ['user-1'],
        );

        expect(result, Failure<RaffleResult, RaffleFailure>(expected));
      });
    }
  });
}
