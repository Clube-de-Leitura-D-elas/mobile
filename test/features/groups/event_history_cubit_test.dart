import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/groups/domain/entities/group_failure.dart';
import 'package:mobile/features/groups/domain/entities/group_meeting.dart';
import 'package:mobile/features/groups/domain/repository/group_repository.dart';
import 'package:mobile/features/groups/presentation/cubit/event_history_cubit.dart';
import 'package:mobile/features/groups/presentation/cubit/event_history_state.dart';
import 'package:mocktail/mocktail.dart';

class MockGroupRepository extends Mock implements GroupRepository {}

void main() {
  late MockGroupRepository mockRepository;

  const meeting = GroupMeeting(
    id: 'meeting-1',
    bookTitle: 'Quarto de Despejo',
    hostName: 'Ana Souza',
    date: '2026-08-22T00:00:00Z',
    location: '',
  );

  setUp(() {
    mockRepository = MockGroupRepository();
  });

  test('keeps loaded meetings immutable', () {
    final sourceMeetings = [meeting];

    final state = EventHistoryLoaded(sourceMeetings);
    sourceMeetings.clear();

    expect(state.meetings, [meeting]);
    expect(() => state.meetings.add(meeting), throwsUnsupportedError);
  });

  blocTest<EventHistoryCubit, EventHistoryState>(
    'emits loading and loaded when event history loads successfully',
    build: () {
      when(
        () => mockRepository.getEventHistory('group-1'),
      ).thenAnswer((_) async => const Success([meeting]));
      return EventHistoryCubit(groupRepository: mockRepository);
    },
    act: (cubit) => cubit.load('group-1'),
    expect: () => [
      const EventHistoryLoading(),
      EventHistoryLoaded(const [meeting]),
    ],
  );

  blocTest<EventHistoryCubit, EventHistoryState>(
    'emits loading and empty when the group has no completed events',
    build: () {
      when(
        () => mockRepository.getEventHistory('group-1'),
      ).thenAnswer((_) async => const Success(<GroupMeeting>[]));
      return EventHistoryCubit(groupRepository: mockRepository);
    },
    act: (cubit) => cubit.load('group-1'),
    expect: () => [const EventHistoryLoading(), const EventHistoryEmpty()],
  );

  blocTest<EventHistoryCubit, EventHistoryState>(
    'emits loading and error when event history loading fails',
    build: () {
      when(() => mockRepository.getEventHistory('group-1')).thenAnswer(
        (_) async => const Failure(
          GroupEventHistoryFailure(message: 'Falha ao carregar histórico'),
        ),
      );
      return EventHistoryCubit(groupRepository: mockRepository);
    },
    act: (cubit) => cubit.load('group-1'),
    expect: () => [
      const EventHistoryLoading(),
      const EventHistoryError('Falha ao carregar histórico'),
    ],
  );

  test('does not emit a result after being closed during a load', () async {
    final response = Completer<Result<List<GroupMeeting>, GroupFailure>>();
    when(
      () => mockRepository.getEventHistory('group-1'),
    ).thenAnswer((_) => response.future);
    final cubit = EventHistoryCubit(groupRepository: mockRepository);
    final states = <EventHistoryState>[];
    final subscription = cubit.stream.listen(states.add);

    final load = cubit.load('group-1');
    await cubit.close();
    response.complete(const Success([meeting]));
    await load;
    await subscription.cancel();

    expect(states, [const EventHistoryLoading()]);
  });
}
