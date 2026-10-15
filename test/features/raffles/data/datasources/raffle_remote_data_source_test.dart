import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/supabase/supabase_failure.dart';
import 'package:mobile/core/supabase/supabase_response.dart';
import 'package:mobile/core/supabase/supabase_service.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/raffles/data/datasources/raffle_remote_data_source.dart';
import 'package:mobile/features/raffles/data/models/raffle_participant_model.dart';
import 'package:mocktail/mocktail.dart';

class MockSupabaseService extends Mock implements SupabaseService {}

// Implementação concreta de SupabaseFailure para o ambiente de testes
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
        // Arrange
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

        // Act
        final result = await dataSource.getEligibleParticipants(tMeetingId);

        // Assert
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
        // Arrange
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

        // Act & Assert
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
        // Arrange
        when(
          () => mockSupabaseService.invokeFunction<void>(
            functionName: any(named: 'functionName'),
            body: any(named: 'body'),
          ),
        ).thenAnswer(
          (_) async => const Success(SupabaseResponse<void>(data: null)),
        );

        // Act & Assert
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
        // Arrange
        when(
          () => mockSupabaseService.invokeFunction<void>(
            functionName: any(named: 'functionName'),
            body: any(named: 'body'),
          ),
        ).thenAnswer(
          (_) async =>
              const Failure(TestSupabaseFailure('Erro ao confirmar sorteio')),
        );

        // Act & Assert
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
}
