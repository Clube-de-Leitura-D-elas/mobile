import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/supabase/supabase_failure.dart';
import 'package:mobile/core/supabase/supabase_response.dart';
import 'package:mobile/core/supabase/supabase_service.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/raffles/data/datasources/raffle_remote_data_source.dart';
import 'package:mobile/features/raffles/data/models/raffle_participant_model.dart';
import 'package:mobile/features/raffles/data/models/raffle_result_model.dart';
import 'package:mocktail/mocktail.dart';

class MockSupabaseService extends Mock implements SupabaseService {}

// 422 é como o backend recusa participantes que deixaram de ser elegíveis:
// o repository só distingue esse caso se `kind` e `code` chegarem intactos.
const _staleListFailure = FunctionSupabaseFailure(
  message: 'some participants are not eligible for this raffle',
  code: '422',
  kind: SupabaseFailureKind.validation,
);

Matcher _throwsRemoteException(SupabaseFailure failure) => throwsA(
  isA<RaffleRemoteException>().having(
    (e) => e.failure,
    'failure',
    same(failure),
  ),
);

void main() {
  late RaffleRemoteDataSourceImpl dataSource;
  late MockSupabaseService mockSupabaseService;

  setUp(() {
    mockSupabaseService = MockSupabaseService();
    dataSource = RaffleRemoteDataSourceImpl(
      supabaseService: mockSupabaseService,
    );
  });

  group('getEligibleParticipants', () {
    const tMeetingId = 'meeting-123';
    const tParticipantModel = RaffleParticipantModel(
      id: '1',
      name: 'Ana',
      hasAttended: true,
      isExcludedByRule: false,
    );

    test(
      'deve retornar a lista de participantes quando o invokeFunction for bem-sucedido',
      () async {
        when(
          () =>
              mockSupabaseService.invokeFunction<List<RaffleParticipantModel>>(
                functionName: any(named: 'functionName'),
                body: any(named: 'body'),
                decoder: any(named: 'decoder'),
              ),
        ).thenAnswer((invocation) async {
          final rawDecoder = invocation.namedArguments[#decoder];
          List<RaffleParticipantModel> decodedData = [];

          if (rawDecoder != null) {
            final dummyJson = [
              {
                'id': '1',
                'name': 'Ana',
                'has_attended': true,
                'is_excluded_by_rule': false,
              },
            ];
            decodedData =
                (rawDecoder as Function)(dummyJson)
                    as List<RaffleParticipantModel>;
          }

          return Success(
            SupabaseResponse<List<RaffleParticipantModel>>(data: decodedData),
          );
        });

        final result = await dataSource.getEligibleParticipants(tMeetingId);

        expect(result, isA<List<RaffleParticipantModel>>());
        expect(result.first.name, equals(tParticipantModel.name));
        expect(result.first.hasAttended, equals(true));
        expect(result.first.isExcludedByRule, equals(false));

        verify(
          () =>
              mockSupabaseService.invokeFunction<List<RaffleParticipantModel>>(
                functionName: 'get-eligible-raffle-participants',
                body: {'meeting_id': tMeetingId},
                decoder: any(named: 'decoder'),
              ),
        ).called(1);
      },
    );

    test(
      'deve lançar RaffleRemoteException com a falha original quando o invokeFunction falhar',
      () async {
        when(
          () =>
              mockSupabaseService.invokeFunction<List<RaffleParticipantModel>>(
                functionName: any(named: 'functionName'),
                body: any(named: 'body'),
                decoder: any(named: 'decoder'),
              ),
        ).thenAnswer((_) async => const Failure(_staleListFailure));

        await expectLater(
          dataSource.getEligibleParticipants(tMeetingId),
          _throwsRemoteException(_staleListFailure),
        );
        verify(
          () =>
              mockSupabaseService.invokeFunction<List<RaffleParticipantModel>>(
                functionName: 'get-eligible-raffle-participants',
                body: {'meeting_id': tMeetingId},
                decoder: any(named: 'decoder'),
              ),
        ).called(1);
      },
    );
  });

  group('confirmRaffle', () {
    const tMeetingId = 'meeting-123';
    const tSelectedParticipantIds = ['1', '2'];

    test(
      'deve concluir com sucesso quando o invokeFunction retornar Success',
      () async {
        when(
          () => mockSupabaseService.invokeFunction<void>(
            functionName: any(named: 'functionName'),
            body: any(named: 'body'),
          ),
        ).thenAnswer(
          (_) async => const Success(SupabaseResponse<void>(data: null)),
        );

        await expectLater(
          dataSource.confirmRaffle(tMeetingId, tSelectedParticipantIds),
          completes,
        );

        verify(
          () => mockSupabaseService.invokeFunction<void>(
            functionName: 'confirm-meeting-raffle',
            body: {
              'meeting_id': tMeetingId,
              'eligible_participant_ids': tSelectedParticipantIds,
            },
          ),
        ).called(1);
      },
    );

    test(
      'deve lançar RaffleRemoteException com a falha original quando o confirmRaffle falhar',
      () async {
        when(
          () => mockSupabaseService.invokeFunction<void>(
            functionName: any(named: 'functionName'),
            body: any(named: 'body'),
          ),
        ).thenAnswer((_) async => const Failure(_staleListFailure));

        await expectLater(
          dataSource.confirmRaffle(tMeetingId, tSelectedParticipantIds),
          _throwsRemoteException(_staleListFailure),
        );
        verify(
          () => mockSupabaseService.invokeFunction<void>(
            functionName: 'confirm-meeting-raffle',
            body: {
              'meeting_id': tMeetingId,
              'eligible_participant_ids': tSelectedParticipantIds,
            },
          ),
        ).called(1);
      },
    );
  });

  group('getRaffleResult', () {
    const tMeetingId = 'meeting-123';

    test(
      'deve retornar RaffleResultModel quando houver resultado salvo',
      () async {
        when(
          () => mockSupabaseService.invokeFunction<Map<String, dynamic>?>(
            functionName: any(named: 'functionName'),
            body: any(named: 'body'),
            decoder: any(named: 'decoder'),
          ),
        ).thenAnswer((invocation) async {
          final decoder = invocation.namedArguments[#decoder] as Function;
          final rawMap = {
            'meeting_id': tMeetingId,
            'winner_id': 'w1',
            'winner_name': 'Beatriz',
            'book_title': '1984',
          };
          final decoded = decoder(rawMap) as Map<String, dynamic>?;
          return Success(SupabaseResponse(data: decoded));
        });

        final result = await dataSource.getRaffleResult(tMeetingId);

        expect(result, isNotNull);
        expect(result?.winnerName, 'Beatriz');
        expect(result?.bookTitle, '1984');
      },
    );

    test('deve retornar null quando decoder receber null ou vazio', () async {
      when(
        () => mockSupabaseService.invokeFunction<Map<String, dynamic>?>(
          functionName: any(named: 'functionName'),
          body: any(named: 'body'),
          decoder: any(named: 'decoder'),
        ),
      ).thenAnswer((invocation) async {
        final decoder = invocation.namedArguments[#decoder] as Function;
        final decoded = decoder(<String, dynamic>{}) as Map<String, dynamic>?;
        return Success(SupabaseResponse(data: decoded));
      });

      final result = await dataSource.getRaffleResult(tMeetingId);
      expect(result, isNull);
    });

    test('deve propagar a falha original quando a chamada falhar', () async {
      const failure = FunctionSupabaseFailure(
        message: 'Unable to load raffle data',
        code: '500',
        kind: SupabaseFailureKind.server,
      );
      when(
        () => mockSupabaseService.invokeFunction<Map<String, dynamic>?>(
          functionName: any(named: 'functionName'),
          body: any(named: 'body'),
          decoder: any(named: 'decoder'),
        ),
      ).thenAnswer((_) async => const Failure(failure));

      await expectLater(
        dataSource.getRaffleResult(tMeetingId),
        _throwsRemoteException(failure),
      );
      verify(
        () => mockSupabaseService.invokeFunction<Map<String, dynamic>?>(
          functionName: 'get-meeting-raffle-result',
          body: {'meeting_id': tMeetingId},
          decoder: any(named: 'decoder'),
        ),
      ).called(1);
    });
  });

  group('drawRaffle', () {
    const tMeetingId = 'meeting-123';
    const tModel = RaffleResultModel(
      meetingId: tMeetingId,
      winnerId: 'w1',
      winnerName: 'Beatriz',
      bookTitle: '1984',
    );

    test('deve retornar RaffleResultModel com sucesso', () async {
      when(
        () => mockSupabaseService.invokeFunction<RaffleResultModel>(
          functionName: any(named: 'functionName'),
          body: any(named: 'body'),
          decoder: any(named: 'decoder'),
        ),
      ).thenAnswer((invocation) async {
        final decoder = invocation.namedArguments[#decoder] as Function;
        final decoded = decoder(tModel.toJson()) as RaffleResultModel;
        return Success(SupabaseResponse(data: decoded));
      });

      final result = await dataSource.drawRaffle(
        meetingId: tMeetingId,
        eligibleParticipantIds: ['w1'],
      );

      expect(result.winnerName, 'Beatriz');
      expect(result.bookTitle, '1984');
    });

    test('deve lançar RaffleRemoteException com a falha original', () async {
      when(
        () => mockSupabaseService.invokeFunction<RaffleResultModel>(
          functionName: any(named: 'functionName'),
          body: any(named: 'body'),
          decoder: any(named: 'decoder'),
        ),
      ).thenAnswer((_) async => const Failure(_staleListFailure));

      await expectLater(
        dataSource.drawRaffle(
          meetingId: tMeetingId,
          eligibleParticipantIds: ['w1'],
        ),
        _throwsRemoteException(_staleListFailure),
      );
      verify(
        () => mockSupabaseService.invokeFunction<RaffleResultModel>(
          functionName: 'draw-meeting-raffle',
          body: {
            'meeting_id': tMeetingId,
            'eligible_participant_ids': ['w1'],
          },
          decoder: any(named: 'decoder'),
        ),
      ).called(1);
    });
  });

  group('saveRaffleResult', () {
    const tModel = RaffleResultModel(
      meetingId: 'meeting-123',
      winnerId: 'w1',
      winnerName: 'Beatriz',
      bookTitle: '1984',
    );

    test('deve concluir com sucesso', () async {
      when(
        () => mockSupabaseService.invokeFunction<void>(
          functionName: any(named: 'functionName'),
          body: any(named: 'body'),
        ),
      ).thenAnswer(
        (_) async => const Success(SupabaseResponse<void>(data: null)),
      );

      await expectLater(dataSource.saveRaffleResult(tModel), completes);
    });

    test('deve lançar RaffleRemoteException com a falha original', () async {
      const failure = FunctionSupabaseFailure(
        message: 'raffle already recorded for this meeting',
        code: '409',
        kind: SupabaseFailureKind.conflict,
      );
      when(
        () => mockSupabaseService.invokeFunction<void>(
          functionName: any(named: 'functionName'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => const Failure(failure));

      await expectLater(
        dataSource.saveRaffleResult(tModel),
        _throwsRemoteException(failure),
      );
      verify(
        () => mockSupabaseService.invokeFunction<void>(
          functionName: 'confirm-meeting-raffle-winner',
          body: tModel.toJson(),
        ),
      ).called(1);
    });
  });
}
