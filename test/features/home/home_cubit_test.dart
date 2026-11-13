import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/groups/domain/entities/group_entity.dart';
import 'package:mobile/features/groups/domain/entities/group_failure.dart';
import 'package:mobile/features/groups/domain/entities/group_meeting.dart';
import 'package:mobile/features/groups/domain/repository/group_repository.dart';
import 'package:mobile/features/home/presentation/cubit/home_cubit.dart';
import 'package:mobile/features/home/presentation/cubit/home_state.dart';
import 'package:mocktail/mocktail.dart';

class MockGroupRepository extends Mock implements GroupRepository {}

void main() {
  group('HomeCubit', () {
    late MockGroupRepository repository;

    const testGroup1 = GroupEntity(
      id: '1',
      number: 1,
      participantsCount: 32,
      cityState: 'Porto Alegre, RS',
    );
    const testGroup27 = GroupEntity(
      id: '27',
      number: 27,
      participantsCount: 18,
      cityState: 'Porto Alegre, RS',
    );

    setUp(() => repository = MockGroupRepository());

    HomeCubit build() => HomeCubit(groupRepository: repository);

    test('starts with an initial state', () {
      final cubit = build();
      addTearDown(cubit.close);

      expect(cubit.state, const HomeState());
    });

    blocTest<HomeCubit, HomeState>(
      'loads the authenticated participant groups from the repository',
      build: () {
        when(
          () => repository.getMyGroups(),
        ).thenAnswer((_) async => const Success([testGroup1, testGroup27]));
        return build();
      },
      act: (cubit) => cubit.loadGroups(),
      expect: () => [
        const HomeState(status: HomeStatus.loading),
        const HomeState(
          status: HomeStatus.loaded,
          groups: [testGroup1, testGroup27],
        ),
      ],
      verify: (_) => verify(() => repository.getMyGroups()).called(1),
    );

    blocTest<HomeCubit, HomeState>(
      'emits an error when the groups request fails',
      build: () {
        when(
          () => repository.getMyGroups(),
        ).thenAnswer((_) async => const Failure(GroupListFailure()));
        return build();
      },
      act: (cubit) => cubit.loadGroups(),
      expect: () => [
        const HomeState(status: HomeStatus.loading),
        const HomeState(status: HomeStatus.error, error: GroupListFailure()),
      ],
    );

    blocTest<HomeCubit, HomeState>(
      'updates the search query',
      build: build,
      act: (cubit) => cubit.updateSearch('Porto Alegre'),
      expect: () => [const HomeState(searchQuery: 'Porto Alegre')],
    );

    blocTest<HomeCubit, HomeState>(
      'expands a group card',
      build: build,
      act: (cubit) => cubit.toggleCardExpansion('1'),
      expect: () => [
        const HomeState(expandedGroupIds: {'1'}),
      ],
    );

    blocTest<HomeCubit, HomeState>(
      'collapses an expanded group card',
      build: build,
      act: (cubit) {
        cubit.toggleCardExpansion('1');
        cubit.toggleCardExpansion('1');
      },
      expect: () => [
        const HomeState(expandedGroupIds: {'1'}),
        const HomeState(),
      ],
    );

    GroupMeeting meeting(String id) => GroupMeeting(
      id: id,
      hostName: 'Ana',
      bookTitle: 'Livro',
      date: '08/11/2026',
      location: 'Casa da Ana',
    );

    group('refreshGroups', () {
      const loaded = HomeState(
        status: HomeStatus.loaded,
        groups: [testGroup1],
        expandedGroupIds: {'1'},
      );

      blocTest<HomeCubit, HomeState>(
        'updates the groups without going through loading',
        build: () {
          when(() => repository.getMyGroups()).thenAnswer(
            (_) async => Success([
              testGroup1.copyWith(participantsCount: 33),
              testGroup27,
            ]),
          );
          return build();
        },
        seed: () => loaded,
        act: (cubit) => cubit.refreshGroups(),
        expect: () => [
          HomeState(
            status: HomeStatus.loaded,
            groups: [testGroup1.copyWith(participantsCount: 33), testGroup27],
            expandedGroupIds: const {'1'},
          ),
        ],
      );

      blocTest<HomeCubit, HomeState>(
        'drops the expansion of a group that left the list',
        build: () {
          when(
            () => repository.getMyGroups(),
          ).thenAnswer((_) async => const Success([testGroup27]));
          return build();
        },
        seed: () => loaded,
        act: (cubit) => cubit.refreshGroups(),
        expect: () => [
          const HomeState(status: HomeStatus.loaded, groups: [testGroup27]),
        ],
      );

      blocTest<HomeCubit, HomeState>(
        'keeps what is on screen when the refresh fails',
        build: () {
          when(
            () => repository.getMyGroups(),
          ).thenAnswer((_) async => const Failure(GroupNetworkFailure()));
          return build();
        },
        seed: () => loaded,
        act: (cubit) => cubit.refreshGroups(),
        expect: () => <HomeState>[],
      );

      blocTest<HomeCubit, HomeState>(
        'does nothing before the first load',
        build: build,
        act: (cubit) => cubit.refreshGroups(),
        expect: () => <HomeState>[],
        verify: (_) => verifyNever(() => repository.getMyGroups()),
      );

      blocTest<HomeCubit, HomeState>(
        'expands a group that is new or got a new meeting',
        build: () {
          when(() => repository.getMyGroups()).thenAnswer(
            (_) async => Success([
              testGroup1.copyWith(nextMeeting: meeting('m-1')),
              testGroup27.copyWith(nextMeeting: meeting('m-27')),
            ]),
          );
          return build();
        },
        seed: () =>
            const HomeState(status: HomeStatus.loaded, groups: [testGroup1]),
        act: (cubit) => cubit.refreshGroups(),
        verify: (cubit) => expect(cubit.state.expandedGroupIds, {'1', '27'}),
      );

      blocTest<HomeCubit, HomeState>(
        'keeps a group collapsed when its meeting did not change',
        build: () {
          when(() => repository.getMyGroups()).thenAnswer(
            (_) async =>
                Success([testGroup1.copyWith(nextMeeting: meeting('m-1'))]),
          );
          return build();
        },
        seed: () => HomeState(
          status: HomeStatus.loaded,
          groups: [testGroup1.copyWith(nextMeeting: meeting('m-1'))],
        ),
        act: (cubit) => cubit.refreshGroups(),
        verify: (cubit) => expect(cubit.state.expandedGroupIds, isEmpty),
      );

      blocTest<HomeCubit, HomeState>(
        'reloads when the screen shows an error',
        build: () {
          when(
            () => repository.getMyGroups(),
          ).thenAnswer((_) async => const Success([testGroup1]));
          return build();
        },
        seed: () => const HomeState(status: HomeStatus.error),
        act: (cubit) => cubit.refreshGroups(),
        expect: () => [
          const HomeState(status: HomeStatus.loading),
          const HomeState(status: HomeStatus.loaded, groups: [testGroup1]),
        ],
      );

      test('a slower earlier read does not overwrite the latest one', () async {
        final slow = Completer<Result<List<GroupEntity>, GroupFailure>>();
        var calls = 0;
        when(() => repository.getMyGroups()).thenAnswer(
          (_) => calls++ == 0
              ? slow.future
              : Future.value(const Success([testGroup27])),
        );
        final cubit = build()..emit(loaded);
        addTearDown(cubit.close);

        final refresh = cubit.refreshGroups();
        await cubit.loadGroups();
        slow.complete(const Success([testGroup1]));
        await refresh;

        expect(cubit.state.groups, [testGroup27]);
      });
    });
  });
}
