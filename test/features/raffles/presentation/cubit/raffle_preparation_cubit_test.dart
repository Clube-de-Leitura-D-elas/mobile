import 'dart:async';

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

    test('nao deve emitir se o cubit for fechado antes do resultado', () async {
      final completer =
          Completer<Result<List<RaffleParticipant>, RaffleFailure>>();
      when(
        () => mockRepository.getEligibleParticipants(tMeetingId),
      ).thenAnswer((_) => completer.future);

      final cubit = RafflePreparationCubit(repository: mockRepository);
      final future = cubit.loadEligibleParticipants(tMeetingId);

      await cubit.close();
      completer.complete(const Success([tParticipant]));
      await future;

      expect(cubit.isClosed, isTrue);
    });
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
      expect(state.participants.first.isSelected, isFalse);

      await cubit.close();
    });

    test(
      'nao deve alternar a selecao se o participante estiver isExcludedByRule',
      () async {
        const excludedParticipant = RaffleParticipant(
          id: 'p2',
          name: 'Alana Mendes',
          avatarUrl: null,
          hasAttended: true,
          isExcludedByRule: true,
          isSelected: false,
        );

        when(
          () => mockRepository.getEligibleParticipants(tMeetingId),
        ).thenAnswer((_) async => const Success([excludedParticipant]));

        final cubit = RafflePreparationCubit(repository: mockRepository);
        await cubit.loadEligibleParticipants(tMeetingId);

        cubit.toggleParticipantSelection('p2');

        final state = cubit.state as RafflePreparationLoaded;
        expect(state.participants.first.isSelected, isFalse);

        await cubit.close();
      },
    );
  });

  blocTest<RafflePreparationCubit, RafflePreparationState>(
    'setParticipants mostra as participantes recebidas sem buscar no backend',
    build: () => RafflePreparationCubit(repository: mockRepository),
    act: (cubit) => cubit.setParticipants(const [tParticipant]),
    expect: () => const [
      RafflePreparationLoaded(participants: [tParticipant]),
    ],
    verify: (_) {
      verifyNever(() => mockRepository.getEligibleParticipants(any()));
    },
  );

  group('confirmRaffle', () {
    blocTest<RafflePreparationCubit, RafflePreparationState>(
      'deve emitir estado de submissao e sucesso ao confirmar',
      build: () {
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
        RafflePreparationSuccess(selectedParticipants: [tParticipant]),
      ],
    );

    blocTest<RafflePreparationCubit, RafflePreparationState>(
      'nao repassa ao sorteio quem foi desmarcada',
      build: () {
        when(
          () => mockRepository.confirmRaffle(
            meetingId: any(named: 'meetingId'),
            selectedParticipantIds: any(named: 'selectedParticipantIds'),
          ),
        ).thenAnswer((_) async => const Success(null));
        return RafflePreparationCubit(repository: mockRepository);
      },
      seed: () => RafflePreparationLoaded(
        participants: [
          tParticipant,
          tParticipant.copyWith(id: 'p2', isSelected: false),
        ],
      ),
      act: (cubit) => cubit.confirmRaffle(tMeetingId),
      verify: (cubit) {
        expect(
          cubit.state,
          const RafflePreparationSuccess(selectedParticipants: [tParticipant]),
        );
        verify(
          () => mockRepository.confirmRaffle(
            meetingId: tMeetingId,
            selectedParticipantIds: ['p1'],
          ),
        ).called(1);
      },
    );

    blocTest<RafflePreparationCubit, RafflePreparationState>(
      'deve emitir estado de submissao e erro quando o repositorio retornar falha',
      build: () {
        when(
          () => mockRepository.confirmRaffle(
            meetingId: any(named: 'meetingId'),
            selectedParticipantIds: any(named: 'selectedParticipantIds'),
          ),
        ).thenAnswer(
          (_) async => const Failure(TestRaffleFailure('Erro ao confirmar')),
        );
        return RafflePreparationCubit(repository: mockRepository);
      },
      seed: () => const RafflePreparationLoaded(participants: [tParticipant]),
      act: (cubit) => cubit.confirmRaffle(tMeetingId),
      expect: () => const [
        RafflePreparationLoaded(
          participants: [tParticipant],
          isSubmitting: true,
        ),
        RafflePreparationError('Erro ao confirmar'),
        RafflePreparationLoaded(
          participants: [tParticipant],
          isSubmitting: false,
        ),
      ],
    );

    blocTest<RafflePreparationCubit, RafflePreparationState>(
      'nao deve confirmar nem emitir novos estados quando nenhum participante estiver selecionado',
      build: () => RafflePreparationCubit(repository: mockRepository),
      seed: () => const RafflePreparationLoaded(
        participants: [
          RaffleParticipant(
            id: 'p1',
            name: 'Mariana',
            hasAttended: true,
            isSelected: false,
          ),
        ],
      ),
      act: (cubit) => cubit.confirmRaffle(tMeetingId),
      expect: () => [],
      verify: (_) {
        verifyZeroInteractions(mockRepository);
      },
    );

    test('nao deve emitir se o cubit for fechado antes da resposta', () async {
      final completer = Completer<Result<void, RaffleFailure>>();
      when(
        () => mockRepository.confirmRaffle(
          meetingId: any(named: 'meetingId'),
          selectedParticipantIds: any(named: 'selectedParticipantIds'),
        ),
      ).thenAnswer((_) => completer.future);

      final cubit = RafflePreparationCubit(repository: mockRepository);
      cubit.emit(const RafflePreparationLoaded(participants: [tParticipant]));

      final future = cubit.confirmRaffle(tMeetingId);
      await cubit.close();
      completer.complete(const Success(null));
      await future;

      expect(cubit.isClosed, isTrue);
    });
  });
}
