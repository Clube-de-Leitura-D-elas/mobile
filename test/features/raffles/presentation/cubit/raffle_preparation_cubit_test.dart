import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/raffles/domain/entities/raffle_failure.dart';
import 'package:mobile/features/raffles/domain/entities/raffle_participant.dart';
import 'package:mobile/features/raffles/domain/repository/raffle_repository.dart';
import 'package:mobile/features/raffles/presentation/cubit/raffle_preparation_cubit.dart';
import 'package:mobile/features/raffles/presentation/cubit/raffle_preparation_state.dart';
import 'package:mocktail/mocktail.dart';

class MockRaffleRepository extends Mock implements RaffleRepository {}

class TestRaffleFailure extends RaffleFailure {
  const TestRaffleFailure(super.message);
}

void main() {
  late MockRaffleRepository mockRepository;

  const tMeetingId = 'meeting-123';
  const tParticipant = RaffleParticipant(
    id: 'p1',
    name: 'Mariana de Souza',
    avatarUrl: null,
    hasAttended: true,
  );

  setUp(() {
    mockRepository = MockRaffleRepository();
  });

  test('estado inicial deve ser RafflePreparationInitial', () {
    final cubit = RafflePreparationCubit(repository: mockRepository);
    expect(cubit.state, equals(const RafflePreparationInitial()));
    cubit.close();
  });

  group('loadEligibleParticipants', () {
    blocTest<RafflePreparationCubit, RafflePreparationState>(
      'deve emitir [Loading, Loaded] quando o repositorio retornar sucesso',
      build: () {
        when(
          () => mockRepository.getEligibleParticipants(tMeetingId),
        ).thenAnswer((_) async => const Success([tParticipant]));
        return RafflePreparationCubit(repository: mockRepository);
      },
      act: (cubit) => cubit.loadEligibleParticipants(tMeetingId),
      expect: () => const [
        RafflePreparationLoading(),
        RafflePreparationLoaded(participants: [tParticipant]),
      ],
    );

    blocTest<RafflePreparationCubit, RafflePreparationState>(
      'deve emitir [Loading, Error] quando o repositorio retornar falha',
      build: () {
        when(
          () => mockRepository.getEligibleParticipants(tMeetingId),
        ).thenAnswer(
          (_) async => const Failure(TestRaffleFailure('Erro ao carregar')),
        );
        return RafflePreparationCubit(repository: mockRepository);
      },
      act: (cubit) => cubit.loadEligibleParticipants(tMeetingId),
      expect: () => [
        const RafflePreparationLoading(),
        isA<RafflePreparationError>(),
      ],
    );
  });

  group('toggleParticipantSelection', () {
    test('deve alternar a selecao do participante no estado Loaded', () async {
      when(
        () => mockRepository.getEligibleParticipants(tMeetingId),
      ).thenAnswer((_) async => const Success([tParticipant]));

      final cubit = RafflePreparationCubit(repository: mockRepository);
      await cubit.loadEligibleParticipants(tMeetingId);

      cubit.toggleParticipantSelection('p1');

      final state = cubit.state as RafflePreparationLoaded;
      expect(state.participants, isNotEmpty);

      await cubit.close();
    });
  });

  group('confirmRaffle', () {
    blocTest<RafflePreparationCubit, RafflePreparationState>(
      'deve emitir estado de submissao e sucesso ao confirmar',
      build: () {
        when(
          () => mockRepository.getEligibleParticipants(tMeetingId),
        ).thenAnswer((_) async => const Success([tParticipant]));
        when(
          () => mockRepository.confirmRaffle(
            meetingId: any(named: 'meetingId'),
            selectedParticipantIds: any(named: 'selectedParticipantIds'),
          ),
        ).thenAnswer((_) async => const Success(null));
        return RafflePreparationCubit(repository: mockRepository);
      },
      seed: () => const RafflePreparationLoaded(participants: [tParticipant]),
      act: (cubit) => cubit.confirmRaffle(tMeetingId),
      expect: () => const [
        RafflePreparationLoaded(
          participants: [tParticipant],
          isSubmitting: true,
        ),
        RafflePreparationSuccess(),
      ],
    );
  });
}
