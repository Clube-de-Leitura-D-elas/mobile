import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/raffles/domain/entities/raffle_failure.dart';
import 'package:mobile/features/raffles/domain/entities/raffle_participant.dart';
import 'package:mobile/features/raffles/domain/entities/raffle_result.dart';
import 'package:mobile/features/raffles/domain/repository/raffle_repository.dart';
import 'package:mobile/features/raffles/presentation/cubit/raffle_execution_cubit.dart';
import 'package:mobile/features/raffles/presentation/cubit/raffle_execution_state.dart';
import 'package:mocktail/mocktail.dart';

class MockRaffleRepository extends Mock implements RaffleRepository {}

class TestRaffleFailure extends RaffleFailure {
  const TestRaffleFailure(super.message);
}

void main() {
  late MockRaffleRepository mockRepository;

  const tMeetingId = 'meeting-123';
  const tMeetingTitle = 'Julho';
  const tParticipant = RaffleParticipant(
    id: 'p1',
    name: 'Ana Beatriz',
    hasAttended: true,
    isSelected: true,
    bookTitle: 'O Pequeno Príncipe',
    bookAuthor: 'Antoine de Saint-Exupéry',
  );

  const tResult = RaffleResult(
    meetingId: tMeetingId,
    winnerId: 'p1',
    winnerName: 'Ana Beatriz',
    bookTitle: 'O Pequeno Príncipe',
    bookAuthor: 'Antoine de Saint-Exupéry',
  );

  const tParticipant2 = RaffleParticipant(
    id: 'p2',
    name: 'Carla Mendes',
    hasAttended: true,
    bookTitle: 'Torto Arado',
  );

  const tResult2 = RaffleResult(
    meetingId: tMeetingId,
    winnerId: 'p2',
    winnerName: 'Carla Mendes',
    bookTitle: 'Torto Arado',
  );

  setUp(() {
    mockRepository = MockRaffleRepository();
  });

  test('estado inicial deve ser RaffleExecutionInitial', () {
    final cubit = RaffleExecutionCubit(repository: mockRepository);
    expect(cubit.state, equals(const RaffleExecutionInitial()));
    cubit.close();
  });

  group('load', () {
    blocTest<RaffleExecutionCubit, RaffleExecutionState>(
      'retry repete o ultimo carregamento depois de um erro',
      build: () {
        var calls = 0;
        when(() => mockRepository.getRaffleResult(tMeetingId)).thenAnswer(
          (_) async => calls++ == 0
              ? const Failure(TestRaffleFailure('Erro de rede'))
              : const Success(null),
        );
        return RaffleExecutionCubit(repository: mockRepository);
      },
      act: (cubit) async {
        await cubit.load(
          tMeetingId,
          meetingTitle: tMeetingTitle,
          participants: const [tParticipant],
        );
        await cubit.retry();
      },
      expect: () => const [
        RaffleExecutionLoading(),
        RaffleExecutionError('Erro de rede'),
        RaffleExecutionLoading(),
        RaffleExecutionReady(
          meetingId: tMeetingId,
          meetingTitle: tMeetingTitle,
          eligibleParticipants: [tParticipant],
        ),
      ],
    );

    blocTest<RaffleExecutionCubit, RaffleExecutionState>(
      'usa as participantes recebidas da preparacao sem buscar no backend',
      build: () {
        when(
          () => mockRepository.getRaffleResult(tMeetingId),
        ).thenAnswer((_) async => const Success(null));
        return RaffleExecutionCubit(repository: mockRepository);
      },
      act: (cubit) => cubit.load(
        tMeetingId,
        meetingTitle: tMeetingTitle,
        participants: const [tParticipant],
      ),
      expect: () => const [
        RaffleExecutionLoading(),
        RaffleExecutionReady(
          meetingId: tMeetingId,
          meetingTitle: tMeetingTitle,
          eligibleParticipants: [tParticipant],
        ),
      ],
      verify: (_) {
        verifyNever(() => mockRepository.getEligibleParticipants(any()));
      },
    );

    blocTest<RaffleExecutionCubit, RaffleExecutionState>(
      'deve emitir [Loading, ResultLoaded] quando ja houver resultado salvo (consulta posterior consistente)',
      build: () {
        when(
          () => mockRepository.getRaffleResult(tMeetingId),
        ).thenAnswer((_) async => const Success(tResult));
        return RaffleExecutionCubit(repository: mockRepository);
      },
      act: (cubit) => cubit.load(tMeetingId, meetingTitle: tMeetingTitle),
      expect: () => const [
        RaffleExecutionLoading(),
        RaffleExecutionResultLoaded(
          meetingId: tMeetingId,
          meetingTitle: tMeetingTitle,
          result: tResult,
          isPersisted: true,
        ),
      ],
    );

    blocTest<RaffleExecutionCubit, RaffleExecutionState>(
      'deve emitir [Loading, Error] quando falhar ao consultar resultado existente',
      build: () {
        when(() => mockRepository.getRaffleResult(tMeetingId)).thenAnswer(
          (_) async => const Failure(TestRaffleFailure('Erro de conexão')),
        );
        return RaffleExecutionCubit(repository: mockRepository);
      },
      act: (cubit) => cubit.load(tMeetingId, meetingTitle: tMeetingTitle),
      expect: () => const [
        RaffleExecutionLoading(),
        RaffleExecutionError('Erro de conexão'),
      ],
    );

    blocTest<RaffleExecutionCubit, RaffleExecutionState>(
      'deve emitir [Loading, Ready] quando nao houver resultado e houver participantes elegiveis',
      build: () {
        when(
          () => mockRepository.getRaffleResult(tMeetingId),
        ).thenAnswer((_) async => const Success(null));
        when(
          () => mockRepository.getEligibleParticipants(tMeetingId),
        ).thenAnswer((_) async => const Success([tParticipant]));
        return RaffleExecutionCubit(repository: mockRepository);
      },
      act: (cubit) => cubit.load(tMeetingId, meetingTitle: tMeetingTitle),
      expect: () => const [
        RaffleExecutionLoading(),
        RaffleExecutionReady(
          meetingId: tMeetingId,
          meetingTitle: tMeetingTitle,
          eligibleParticipants: [tParticipant],
        ),
      ],
    );

    blocTest<RaffleExecutionCubit, RaffleExecutionState>(
      'deve emitir [Loading, NoEligible] quando a lista de elegiveis for vazia',
      build: () {
        when(
          () => mockRepository.getRaffleResult(tMeetingId),
        ).thenAnswer((_) async => const Success(null));
        when(
          () => mockRepository.getEligibleParticipants(tMeetingId),
        ).thenAnswer((_) async => const Success([]));
        return RaffleExecutionCubit(repository: mockRepository);
      },
      act: (cubit) => cubit.load(tMeetingId, meetingTitle: tMeetingTitle),
      expect: () => const [
        RaffleExecutionLoading(),
        RaffleExecutionNoEligible(
          meetingId: tMeetingId,
          meetingTitle: tMeetingTitle,
        ),
      ],
    );

    blocTest<RaffleExecutionCubit, RaffleExecutionState>(
      'deve emitir [Loading, Error] quando a busca falhar',
      build: () {
        when(
          () => mockRepository.getRaffleResult(tMeetingId),
        ).thenAnswer((_) async => const Success(null));
        when(
          () => mockRepository.getEligibleParticipants(tMeetingId),
        ).thenAnswer(
          (_) async => const Failure(TestRaffleFailure('Erro de conexão')),
        );
        return RaffleExecutionCubit(repository: mockRepository);
      },
      act: (cubit) => cubit.load(tMeetingId, meetingTitle: tMeetingTitle),
      expect: () => [
        const RaffleExecutionLoading(),
        isA<RaffleExecutionError>(),
      ],
    );

    test('nao deve emitir estado se cubit for fechado durante await', () async {
      final completer = Completer<Result<RaffleResult?, RaffleFailure>>();
      when(
        () => mockRepository.getRaffleResult(tMeetingId),
      ).thenAnswer((_) => completer.future);

      final cubit = RaffleExecutionCubit(repository: mockRepository);
      final future = cubit.load(tMeetingId);

      await cubit.close();
      completer.complete(const Success(null));
      await future;

      expect(cubit.isClosed, isTrue);
    });
  });

  group('draw', () {
    blocTest<RaffleExecutionCubit, RaffleExecutionState>(
      'deve emitir [isDrawing, ResultLoaded] sem a sorteada na lista ao sortear a partir de Ready',
      build: () {
        when(
          () => mockRepository.drawRaffle(
            meetingId: tMeetingId,
            eligibleParticipantIds: ['p1', 'p2'],
          ),
        ).thenAnswer((_) async => const Success(tResult));
        return RaffleExecutionCubit(repository: mockRepository);
      },
      seed: () => const RaffleExecutionReady(
        meetingId: tMeetingId,
        meetingTitle: tMeetingTitle,
        eligibleParticipants: [tParticipant, tParticipant2],
      ),
      act: (cubit) => cubit.draw(),
      expect: () => const [
        RaffleExecutionReady(
          meetingId: tMeetingId,
          meetingTitle: tMeetingTitle,
          eligibleParticipants: [tParticipant, tParticipant2],
          isDrawing: true,
        ),
        RaffleExecutionResultLoaded(
          meetingId: tMeetingId,
          meetingTitle: tMeetingTitle,
          result: tResult,
          eligibleParticipants: [tParticipant2],
          isPersisted: false,
        ),
      ],
    );

    blocTest<RaffleExecutionCubit, RaffleExecutionState>(
      'deve sortear novamente sem a sorteada anterior e esvaziar a lista na ultima',
      build: () {
        when(
          () => mockRepository.drawRaffle(
            meetingId: tMeetingId,
            eligibleParticipantIds: ['p2'],
          ),
        ).thenAnswer((_) async => const Success(tResult2));
        return RaffleExecutionCubit(repository: mockRepository);
      },
      seed: () => const RaffleExecutionResultLoaded(
        meetingId: tMeetingId,
        meetingTitle: tMeetingTitle,
        result: tResult,
        eligibleParticipants: [tParticipant2],
      ),
      act: (cubit) => cubit.draw(),
      expect: () => const [
        RaffleExecutionResultLoaded(
          meetingId: tMeetingId,
          meetingTitle: tMeetingTitle,
          result: tResult,
          eligibleParticipants: [tParticipant2],
          isSubmitting: true,
        ),
        RaffleExecutionResultLoaded(
          meetingId: tMeetingId,
          meetingTitle: tMeetingTitle,
          result: tResult2,
          eligibleParticipants: [],
        ),
      ],
    );

    blocTest<RaffleExecutionCubit, RaffleExecutionState>(
      'nao sorteia novamente quando nao ha mais ninguem para sortear',
      build: () => RaffleExecutionCubit(repository: mockRepository),
      seed: () => const RaffleExecutionResultLoaded(
        meetingId: tMeetingId,
        meetingTitle: tMeetingTitle,
        result: tResult,
      ),
      act: (cubit) => cubit.draw(),
      expect: () => const <RaffleExecutionState>[],
      verify: (_) {
        verifyNever(
          () => mockRepository.drawRaffle(
            meetingId: any(named: 'meetingId'),
            eligibleParticipantIds: any(named: 'eligibleParticipantIds'),
          ),
        );
      },
    );

    blocTest<RaffleExecutionCubit, RaffleExecutionState>(
      'deve emitir NoEligible se a lista de participantes elegiveis for vazia ao sortear',
      build: () => RaffleExecutionCubit(repository: mockRepository),
      seed: () => const RaffleExecutionReady(
        meetingId: tMeetingId,
        meetingTitle: tMeetingTitle,
        eligibleParticipants: [],
      ),
      act: (cubit) => cubit.draw(),
      expect: () => const [
        RaffleExecutionNoEligible(
          meetingId: tMeetingId,
          meetingTitle: tMeetingTitle,
        ),
      ],
    );

    blocTest<RaffleExecutionCubit, RaffleExecutionState>(
      'deve emitir Error se a chamada de sorteio falhar',
      build: () {
        when(
          () => mockRepository.drawRaffle(
            meetingId: any(named: 'meetingId'),
            eligibleParticipantIds: any(named: 'eligibleParticipantIds'),
          ),
        ).thenAnswer(
          (_) async => const Failure(TestRaffleFailure('Erro no sorteio')),
        );
        return RaffleExecutionCubit(repository: mockRepository);
      },
      seed: () => const RaffleExecutionReady(
        meetingId: tMeetingId,
        meetingTitle: tMeetingTitle,
        eligibleParticipants: [tParticipant],
      ),
      act: (cubit) => cubit.draw(),
      expect: () => [
        const RaffleExecutionReady(
          meetingId: tMeetingId,
          meetingTitle: tMeetingTitle,
          eligibleParticipants: [tParticipant],
          isDrawing: true,
        ),
        isA<RaffleExecutionError>(),
      ],
    );
  });

  group('copyWith', () {
    test('deve preservar valores de RaffleExecutionReady quando omitidos', () {
      const state = RaffleExecutionReady(
        meetingId: tMeetingId,
        meetingTitle: tMeetingTitle,
        eligibleParticipants: [tParticipant],
        isDrawing: true,
      );

      expect(state.copyWith(), state);
    });

    test(
      'deve preservar valores de RaffleExecutionResultLoaded quando omitidos',
      () {
        const state = RaffleExecutionResultLoaded(
          meetingId: tMeetingId,
          meetingTitle: tMeetingTitle,
          result: tResult,
          eligibleParticipants: [tParticipant],
          isPersisted: true,
          isSubmitting: true,
        );

        expect(state.copyWith(), state);
      },
    );
  });

  group('confirmResult', () {
    blocTest<RaffleExecutionCubit, RaffleExecutionState>(
      'deve salvar o resultado e emitir [isSubmitting: true, ResultLoaded persistido]',
      build: () {
        when(
          () => mockRepository.saveRaffleResult(tResult),
        ).thenAnswer((_) async => const Success(null));
        return RaffleExecutionCubit(repository: mockRepository);
      },
      seed: () => const RaffleExecutionResultLoaded(
        meetingId: tMeetingId,
        meetingTitle: tMeetingTitle,
        result: tResult,
        isPersisted: false,
      ),
      act: (cubit) => cubit.confirmResult(),
      expect: () => const [
        RaffleExecutionResultLoaded(
          meetingId: tMeetingId,
          meetingTitle: tMeetingTitle,
          result: tResult,
          isPersisted: false,
          isSubmitting: true,
        ),
        RaffleExecutionSuccess(tResult),
      ],
    );

    blocTest<RaffleExecutionCubit, RaffleExecutionState>(
      'deve emitir Error quando a confirmacao falhar',
      build: () {
        when(() => mockRepository.saveRaffleResult(tResult)).thenAnswer(
          (_) async => const Failure(TestRaffleFailure('Erro ao salvar')),
        );
        return RaffleExecutionCubit(repository: mockRepository);
      },
      seed: () => const RaffleExecutionResultLoaded(
        meetingId: tMeetingId,
        meetingTitle: tMeetingTitle,
        result: tResult,
        isPersisted: false,
      ),
      act: (cubit) => cubit.confirmResult(),
      expect: () => const [
        RaffleExecutionResultLoaded(
          meetingId: tMeetingId,
          meetingTitle: tMeetingTitle,
          result: tResult,
          isPersisted: false,
          isSubmitting: true,
        ),
        RaffleExecutionError('Erro ao salvar'),
      ],
    );
  });
}
