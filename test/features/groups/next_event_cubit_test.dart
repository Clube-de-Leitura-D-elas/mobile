import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/groups/domain/entities/group_failure.dart';
import 'package:mobile/features/groups/domain/entities/next_event_entity.dart';
import 'package:mobile/features/groups/domain/repository/group_repository.dart';
import 'package:mobile/features/groups/presentation/cubit/next_event_cubit.dart';
import 'package:mobile/features/groups/presentation/cubit/next_event_state.dart';
import 'package:mocktail/mocktail.dart';

class MockGroupRepository extends Mock implements GroupRepository {}

void main() {
  late MockGroupRepository mockRepository;

  const event = NextEventEntity(
    location: 'Porto Alegre, RS',
    date: '2026-09-15T21:30:00Z',
    hostName: 'Roberta',
  );

  setUp(() {
    mockRepository = MockGroupRepository();
  });

  blocTest<NextEventCubit, NextEventState>(
    'emits loading then loaded when event exists',
    build: () {
      when(
        () => mockRepository.getNextEvent('group-1'),
      ).thenAnswer((_) async => const Success(event));
      return NextEventCubit(groupRepository: mockRepository);
    },
    act: (cubit) => cubit.load('group-1'),
    expect: () => [
      const NextEventLoading(),
      const NextEventLoaded(event),
    ],
  );

  blocTest<NextEventCubit, NextEventState>(
    'emits loading then empty when group has no next event',
    build: () {
      when(
        () => mockRepository.getNextEvent('group-1'),
      ).thenAnswer((_) async => const Success(null));
      return NextEventCubit(groupRepository: mockRepository);
    },
    act: (cubit) => cubit.load('group-1'),
    expect: () => [const NextEventLoading(), const NextEventEmpty()],
  );

  blocTest<NextEventCubit, NextEventState>(
    'emits loading then error when request fails',
    build: () {
      when(
        () => mockRepository.getNextEvent('group-1'),
      ).thenAnswer(
        (_) async => const Failure(
          GroupNextEventFailure(message: 'Falha ao carregar próximo evento'),
        ),
      );
      return NextEventCubit(groupRepository: mockRepository);
    },
    act: (cubit) => cubit.load('group-1'),
    expect: () => [
      const NextEventLoading(),
      const NextEventError('Falha ao carregar próximo evento'),
    ],
  );

  test('does not emit after being closed during load', () async {
    final response =
        Completer<Result<NextEventEntity?, GroupFailure>>();
    when(
      () => mockRepository.getNextEvent('group-1'),
    ).thenAnswer((_) => response.future);

    final cubit = NextEventCubit(groupRepository: mockRepository);
    final states = <NextEventState>[];
    final subscription = cubit.stream.listen(states.add);

    final load = cubit.load('group-1');
    await cubit.close();
    response.complete(const Success(event));
    await load;
    await subscription.cancel();

    expect(states, [const NextEventLoading()]);
  });
}
