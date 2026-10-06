import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/groups/domain/entities/group_failure.dart';
import 'package:mobile/features/groups/domain/entities/meeting_details_entity.dart';
import 'package:mobile/features/groups/domain/repository/group_repository.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_details_cubit.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_details_state.dart';
import 'package:mocktail/mocktail.dart';

class MockGroupRepository extends Mock implements GroupRepository {}

void main() {
  late MockGroupRepository mockRepository;

  const meeting = MeetingDetailsEntity(
    id: 'meeting-1',
    number: 12,
    bookTitle: 'Dom Casmurro',
    hostName: 'Beatriz Souza',
  );

  setUp(() {
    mockRepository = MockGroupRepository();
  });

  blocTest<MeetingDetailsCubit, MeetingDetailsState>(
    'emits loading and loaded when the meeting loads successfully',
    build: () {
      when(
        () => mockRepository.getMeetingDetails('meeting-1'),
      ).thenAnswer((_) async => const Success(meeting));
      return MeetingDetailsCubit(groupRepository: mockRepository);
    },
    act: (cubit) => cubit.load('meeting-1'),
    expect: () => [
      const MeetingDetailsLoading(),
      const MeetingDetailsLoaded(meeting),
    ],
  );

  blocTest<MeetingDetailsCubit, MeetingDetailsState>(
    'emits loading and error when loading fails',
    build: () {
      when(
        () => mockRepository.getMeetingDetails('meeting-1'),
      ).thenAnswer((_) async => const Failure(MeetingNotFoundFailure()));
      return MeetingDetailsCubit(groupRepository: mockRepository);
    },
    act: (cubit) => cubit.load('meeting-1'),
    expect: () => [
      const MeetingDetailsLoading(),
      const MeetingDetailsError('Encontro não encontrado.'),
    ],
  );

  test('does not emit a result after being closed during a load', () async {
    final response = Completer<Result<MeetingDetailsEntity, GroupFailure>>();
    when(
      () => mockRepository.getMeetingDetails('meeting-1'),
    ).thenAnswer((_) => response.future);
    final cubit = MeetingDetailsCubit(groupRepository: mockRepository);
    final states = <MeetingDetailsState>[];
    final subscription = cubit.stream.listen(states.add);

    final load = cubit.load('meeting-1');
    await cubit.close();
    response.complete(const Success(meeting));
    await load;
    await subscription.cancel();

    expect(states, [const MeetingDetailsLoading()]);
  });
}
