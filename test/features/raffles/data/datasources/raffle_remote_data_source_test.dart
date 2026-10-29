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

class TestSupabaseFailure extends SupabaseFailure {
  const TestSupabaseFailure(String message) : super(message: message);
}

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
      'deve lançar Exception quando o invokeFunction retornar uma falha',
      () async {
        when(
          () =>
              mockSupabaseService.invokeFunction<List<RaffleParticipantModel>>(
                functionName: any(named: 'functionName'),
                body: any(named: 'body'),
                decoder: any(named: 'decoder'),
              ),
        ).thenAnswer(
          (_) async => const Failure(
            TestSupabaseFailure('Erro ao carregar participantes'),
          ),
        );

        expect(
          () async => await dataSource.getEligibleParticipants(tMeetingId),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Erro ao carregar participantes'),
            ),
          ),
        );
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
      'deve lançar Exception quando o confirmRaffle retornar uma falha',
      () async {
        when(
          () => mockSupabaseService.invokeFunction<void>(
            functionName: any(named: 'functionName'),
            body: any(named: 'body'),
          ),
        ).thenAnswer(
          (_) async =>
              const Failure(TestSupabaseFailure('Erro ao confirmar sorteio')),
        );

        expect(
          () async => await dataSource.confirmRaffle(
            tMeetingId,
            tSelectedParticipantIds,
          ),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Erro ao confirmar sorteio'),
            ),
          ),
        );
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

    test('deve propagar erro quando a chamada falhar', () async {
      when(
        () => mockSupabaseService.invokeFunction<Map<String, dynamic>?>(
          functionName: any(named: 'functionName'),
          body: any(named: 'body'),
          decoder: any(named: 'decoder'),
        ),
      ).thenAnswer(
        (_) async => const Failure(TestSupabaseFailure('Not found')),
      );

      expect(
        () => dataSource.getRaffleResult(tMeetingId),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            contains('Not found'),
          ),
        ),
      );
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

    test('deve lançar Exception em caso de falha', () async {
      when(
        () => mockSupabaseService.invokeFunction<RaffleResultModel>(
          functionName: any(named: 'functionName'),
          body: any(named: 'body'),
          decoder: any(named: 'decoder'),
        ),
      ).thenAnswer(
        (_) async => const Failure(TestSupabaseFailure('Falha ao sortear')),
      );

      expect(
        () => dataSource.drawRaffle(
          meetingId: tMeetingId,
          eligibleParticipantIds: ['w1'],
        ),
        throwsA(isA<Exception>()),
      );
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

    test('deve lançar Exception em caso de erro', () async {
      when(
        () => mockSupabaseService.invokeFunction<void>(
          functionName: any(named: 'functionName'),
          body: any(named: 'body'),
        ),
      ).thenAnswer(
        (_) async => const Failure(TestSupabaseFailure('Erro ao salvar')),
      );

      expect(
        () => dataSource.saveRaffleResult(tModel),
        throwsA(isA<Exception>()),
      );
    });
  });
}
