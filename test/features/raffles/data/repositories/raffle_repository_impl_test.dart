import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/raffles/data/datasources/raffle_remote_data_source.dart';
import 'package:mobile/features/raffles/data/models/raffle_participant_model.dart';
import 'package:mobile/features/raffles/data/repositories/raffle_repository_impl.dart';
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
    test(
      'deve chamar o data source e retornar a lista de participantes com sucesso',
      () async {
        const tModel = RaffleParticipantModel(
          id: 'p1',
          name: 'Mariana de Souza',
          avatarUrl: null,
          hasAttended: true,
        );

        when(
          () => mockDataSource.getEligibleParticipants('m1'),
        ).thenAnswer((_) async => [tModel]);

        final result = await repository.getEligibleParticipants('m1');

        verify(() => mockDataSource.getEligibleParticipants('m1')).called(1);
        expect(result, isNotNull);
      },
    );
  });
}
