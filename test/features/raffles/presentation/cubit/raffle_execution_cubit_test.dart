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
      'deve emitir [isDrawing, ResultLoaded] ao sortear com sucesso a partir de Ready',
      build: () {
        when(
          () => mockRepository.drawRaffle(
            meetingId: tMeetingId,
            eligibleParticipantIds: ['p1'],
          ),
        ).thenAnswer((_) async => const Success(tResult));
        return RaffleExecutionCubit(repository: mockRepository);
      },
      seed: () => const RaffleExecutionReady(
        meetingId: tMeetingId,
        meetingTitle: tMeetingTitle,
        eligibleParticipants: [tParticipant],
      ),
      act: (cubit) => cubit.draw(),
      expect: () => const [
        RaffleExecutionReady(
          meetingId: tMeetingId,
          meetingTitle: tMeetingTitle,
          eligibleParticipants: [tParticipant],
          isDrawing: true,
        ),
        RaffleExecutionResultLoaded(
          meetingId: tMeetingId,
          meetingTitle: tMeetingTitle,
          result: tResult,
          eligibleParticipants: [tParticipant],
          isPersisted: false,
        ),
      ],
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

  group('confirmResult', () {
    blocTest<RaffleExecutionCubit, RaffleExecutionState>(
      'deve salvar o resultado e emitir [isSubmitting: true, Success, isSubmitting: false, isPersisted: true]',
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
        RaffleExecutionResultLoaded(
          meetingId: tMeetingId,
          meetingTitle: tMeetingTitle,
          result: tResult,
          isPersisted: true,
          isSubmitting: false,
        ),
      ],
    );

    blocTest<RaffleExecutionCubit, RaffleExecutionState>(
      'deve emitir Error quando a confirmacao falhar',
      build: () {
        when(
          () => mockRepository.saveRaffleResult(tResult),
        ).thenAnswer(
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
        RaffleExecutionResultLoaded(
          meetingId: tMeetingId,
          meetingTitle: tMeetingTitle,
          result: tResult,
          isPersisted: false,
          isSubmitting: false,
        ),
      ],
    );
  });
}
