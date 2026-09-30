import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/groups/domain/entities/group_entity.dart';
import 'package:mobile/features/home/presentation/cubit/home_cubit.dart';
import 'package:mobile/features/home/presentation/cubit/home_state.dart';

void main() {
  group('HomeCubit', () {
    late HomeCubit homeCubit;

    const testGroup1 = GroupEntity(
      id: '1',
      name: 'Grupo 1',
      participantsCount: 32,
      cityState: 'Porto Alegre, RS',
      hasPendingResponse: true,
    );

    const testGroup27 = GroupEntity(
      id: '27',
      name: 'Grupo 27',
      participantsCount: 18,
      cityState: 'Porto Alegre, RS',
      hasPendingResponse: false,
    );

    setUp(() {
      homeCubit = HomeCubit();
    });

    tearDown(() {
      homeCubit.close();
    });

    test('Given fresh HomeCubit, When initialized, Then state is HomeStatus.initial with defaults', () {
      expect(homeCubit.state.status, equals(HomeStatus.initial));
      expect(homeCubit.state.groups, isEmpty);
      expect(homeCubit.state.expandedGroupIds, isEmpty);
      expect(homeCubit.state.selectedFilterIndex, equals(0));
      expect(homeCubit.state.unansweredCount, equals(0));
    });

    blocTest<HomeCubit, HomeState>(
      'Given initial state, When loadGroups is called with groups, Then emits loading and loaded with groups',
      build: () => homeCubit,
      act: (cubit) => cubit.loadGroups(initialGroups: [testGroup1, testGroup27]),
      expect: () => [
        const HomeState(status: HomeStatus.loading),
        const HomeState(
          status: HomeStatus.loaded,
          groups: [testGroup1, testGroup27],
          expandedGroupIds: {'1'},
        ),
      ],
      verify: (cubit) {
        expect(cubit.state.isGroupExpanded('1'), isTrue);
        expect(cubit.state.isGroupExpanded('27'), isFalse);
        expect(cubit.state.unansweredCount, equals(1));
      },
    );

    blocTest<HomeCubit, HomeState>(
      'Given initial state, When loadGroups is called without parameters, Then loads default MockGroups',
      build: () => homeCubit,
      act: (cubit) => cubit.loadGroups(),
      expect: () => [
        const HomeState(status: HomeStatus.loading),
        isA<HomeState>()
            .having((s) => s.status, 'status', HomeStatus.loaded)
            .having((s) => s.groups.length, 'groups length', 3)
            .having((s) => s.isGroupExpanded('1'), 'group 1 expanded', isTrue)
            .having((s) => s.isGroupExpanded('27'), 'group 27 expanded', isFalse),
      ],
    );

    blocTest<HomeCubit, HomeState>(
      'Given loaded state with group 1 expanded, When toggleCardExpansion("1") is called, Then group 1 is removed from expandedGroupIds',
      build: () => homeCubit,
      seed: () => const HomeState(
        status: HomeStatus.loaded,
        groups: [testGroup1, testGroup27],
        expandedGroupIds: {'1'},
      ),
      act: (cubit) => cubit.toggleCardExpansion('1'),
      expect: () => [
        const HomeState(
          status: HomeStatus.loaded,
          groups: [testGroup1, testGroup27],
          expandedGroupIds: {},
        ),
      ],
    );

    blocTest<HomeCubit, HomeState>(
      'Given loaded state with group 27 collapsed, When toggleCardExpansion("27") is called, Then group 27 is added to expandedGroupIds independently',
      build: () => homeCubit,
      seed: () => const HomeState(
        status: HomeStatus.loaded,
        groups: [testGroup1, testGroup27],
        expandedGroupIds: {'1'},
      ),
      act: (cubit) => cubit.toggleCardExpansion('27'),
      expect: () => [
        const HomeState(
          status: HomeStatus.loaded,
          groups: [testGroup1, testGroup27],
          expandedGroupIds: {'1', '27'},
        ),
      ],
    );

    blocTest<HomeCubit, HomeState>(
      'Given any state, When selectFilter is called, Then updates selectedFilterIndex',
      build: () => homeCubit,
      act: (cubit) => cubit.selectFilter(1),
      expect: () => [
        const HomeState(selectedFilterIndex: 1),
      ],
    );

    blocTest<HomeCubit, HomeState>(
      'Given any state, When updateSearch is called, Then updates searchQuery',
      build: () => homeCubit,
      act: (cubit) => cubit.updateSearch('Porto Alegre'),
      expect: () => [
        const HomeState(searchQuery: 'Porto Alegre'),
      ],
    );
  });
}
