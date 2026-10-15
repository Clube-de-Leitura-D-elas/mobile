import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/raffles/data/datasources/raffle_remote_data_source.dart';
import 'package:mobile/features/raffles/data/models/raffle_participant_model.dart';
import 'package:mobile/features/raffles/data/repositories/raffle_repository_impl.dart';
import 'package:mobile/features/raffles/domain/entities/raffle_failure.dart';
import 'package:mobile/features/raffles/domain/entities/raffle_participant.dart';
import 'package:mocktail/mocktail.dart';

class MockRaffleRemoteDataSource extends Mock
    implements RaffleRemoteDataSource {}

void main() {
  late RaffleRepositoryImpl repository;
  late MockRaffleRemoteDataSource mockDataSource;

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
        // Arrange
        when(
          () => mockDataSource.getEligibleParticipants(tMeetingId),
        ).thenAnswer((_) async => [tModel]);

        // Act
        final result = await repository.getEligibleParticipants(tMeetingId);

        // Assert
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
        // Arrange
        when(
          () => mockDataSource.getEligibleParticipants(tMeetingId),
        ).thenThrow(Exception('Erro no servidor'));

        // Act
        final result = await repository.getEligibleParticipants(tMeetingId);

        // Assert
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
      // Arrange
      when(
        () => mockDataSource.confirmRaffle(tMeetingId, tSelectedIds),
      ).thenAnswer((_) async => Future.value());

      // Act
      final result = await repository.confirmRaffle(
        meetingId: tMeetingId,
        selectedParticipantIds: tSelectedIds,
      );

      // Assert
      expect(result, isA<Success<void, RaffleFailure>>());
      verify(
        () => mockDataSource.confirmRaffle(tMeetingId, tSelectedIds),
      ).called(1);
      verifyNoMoreInteractions(mockDataSource);
    });

    test(
      'deve retornar Failure quando o data source lançar uma exceção ao confirmar',
      () async {
        // Arrange
        when(
          () => mockDataSource.confirmRaffle(tMeetingId, tSelectedIds),
        ).thenThrow(Exception('Erro ao confirmar sorteio'));

        // Act
        final result = await repository.confirmRaffle(
          meetingId: tMeetingId,
          selectedParticipantIds: tSelectedIds,
        );

        // Assert
        expect(result, isA<Failure<void, RaffleFailure>>());
        verify(
          () => mockDataSource.confirmRaffle(tMeetingId, tSelectedIds),
        ).called(1);
        verifyNoMoreInteractions(mockDataSource);
      },
    );
  });
}
