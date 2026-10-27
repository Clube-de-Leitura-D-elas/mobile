import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/groups/domain/entities/group_failure.dart';
import 'package:mobile/features/groups/domain/entities/meeting_tasks_entity.dart';
import 'package:mobile/features/groups/domain/repository/group_repository.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_tasks_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockGroupRepository extends Mock implements GroupRepository {}

const _tasks = MeetingTasksEntity(
  meetingId: 'meeting-1',
  status: MeetingTaskStatus.created,
  canManageTasks: true,
  canConclude: false,
  schedule: MeetingScheduleTask(done: false),
  record: MeetingRecordTask(MeetingRecordStatus.locked),
);

void main() {
  late MockGroupRepository repository;

  setUp(() => repository = MockGroupRepository());

  MeetingTasksCubit build() =>
      MeetingTasksCubit(groupRepository: repository, meetingId: 'meeting-1');

  blocTest<MeetingTasksCubit, MeetingTasksState>(
    'load emits loading then loaded',
    setUp: () => when(
      () => repository.getMeetingTasks('meeting-1'),
    ).thenAnswer((_) async => const Success(_tasks)),
    build: build,
    act: (cubit) => cubit.load(),
    expect: () => [
      const MeetingTasksLoading(),
      const MeetingTasksLoaded(_tasks),
    ],
  );

  blocTest<MeetingTasksCubit, MeetingTasksState>(
    'load emits the failure message on error',
    setUp: () => when(
      () => repository.getMeetingTasks('meeting-1'),
    ).thenAnswer((_) async => const Failure(MeetingTasksFailure())),
    build: build,
    act: (cubit) => cubit.load(),
    expect: () => [
      const MeetingTasksLoading(),
      MeetingTasksError(const MeetingTasksFailure().message),
    ],
  );

  blocTest<MeetingTasksCubit, MeetingTasksState>(
    'refresh keeps the current content until the new data arrives',
    setUp: () => when(
      () => repository.getMeetingTasks('meeting-1'),
    ).thenAnswer((_) async => const Success(_tasks)),
    build: build,
    seed: () => const MeetingTasksError('erro'),
    act: (cubit) => cubit.refresh(),
    expect: () => [const MeetingTasksLoaded(_tasks)],
  );
}
