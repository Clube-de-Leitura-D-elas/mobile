import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/groups/domain/entities/group_failure.dart';
import 'package:mobile/features/groups/domain/entities/group_participant_entity.dart';
import 'package:mobile/features/groups/domain/repository/group_participants_repository.dart';
import 'package:mobile/features/groups/presentation/cubit/group_participants_cubit.dart';
import 'package:mobile/features/groups/presentation/cubit/group_participants_state.dart';
import 'package:mocktail/mocktail.dart';

class MockGroupParticipantsRepository extends Mock
    implements GroupParticipantsRepository {}

void main() {
  late MockGroupParticipantsRepository repository;

  const coordinator = GroupParticipantEntity(
    id: 'c',
    name: 'Roberta',
    isCoordinator: true,
  );
  const member = GroupParticipantEntity(id: 'm', name: 'Ana');

  setUp(() => repository = MockGroupParticipantsRepository());

  GroupParticipantsCubit build() =>
      GroupParticipantsCubit(participantsRepository: repository);

  test('starts loading', () {
    final cubit = build();
    addTearDown(cubit.close);
    expect(cubit.state, const GroupParticipantsLoading());
  });

  blocTest<GroupParticipantsCubit, GroupParticipantsState>(
    'given members, when loaded, then emits loaded with the list',
    build: () {
      when(
        () => repository.getParticipants('g'),
      ).thenAnswer((_) async => const Success([coordinator, member]));
      return build();
    },
    act: (cubit) => cubit.load('g'),
    expect: () => [
      const GroupParticipantsLoading(),
      const GroupParticipantsLoaded([coordinator, member]),
    ],
  );

  blocTest<GroupParticipantsCubit, GroupParticipantsState>(
    'given only the coordinator, when loaded, then emits loaded with the coordinator',
    build: () {
      when(
        () => repository.getParticipants('g'),
      ).thenAnswer((_) async => const Success([coordinator]));
      return build();
    },
    act: (cubit) => cubit.load('g'),
    expect: () => [
      const GroupParticipantsLoading(),
      const GroupParticipantsLoaded([coordinator]),
    ],
  );

  blocTest<GroupParticipantsCubit, GroupParticipantsState>(
    'given no participants at all, when loaded, then emits empty',
    build: () {
      when(
        () => repository.getParticipants('g'),
      ).thenAnswer((_) async => const Success(<GroupParticipantEntity>[]));
      return build();
    },
    act: (cubit) => cubit.load('g'),
    expect: () => [
      const GroupParticipantsLoading(),
      const GroupParticipantsEmpty(),
    ],
  );

  blocTest<GroupParticipantsCubit, GroupParticipantsState>(
    'given a failure, when loaded, then emits error',
    build: () {
      when(() => repository.getParticipants('g')).thenAnswer(
        (_) async => const Failure(GroupParticipantsFailure(message: 'Falhou')),
      );
      return build();
    },
    act: (cubit) => cubit.load('g'),
    expect: () => [
      const GroupParticipantsLoading(),
      const GroupParticipantsError('Falhou'),
    ],
  );

  blocTest<GroupParticipantsCubit, GroupParticipantsState>(
    'given a previous load, when retrying, then fetches the same group again',
    build: () {
      when(
        () => repository.getParticipants('g'),
      ).thenAnswer((_) async => const Success([member]));
      return build();
    },
    act: (cubit) async {
      await cubit.load('g');
      await cubit.retry();
    },
    expect: () => [
      const GroupParticipantsLoading(),
      const GroupParticipantsLoaded([member]),
      const GroupParticipantsLoading(),
      const GroupParticipantsLoaded([member]),
    ],
    verify: (_) => verify(() => repository.getParticipants('g')).called(2),
  );

  blocTest<GroupParticipantsCubit, GroupParticipantsState>(
    'given no previous load, when retrying, then does nothing',
    build: build,
    act: (cubit) => cubit.retry(),
    expect: () => <GroupParticipantsState>[],
  );
}
