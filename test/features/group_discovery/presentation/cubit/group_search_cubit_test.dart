import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/group_discovery/domain/entities/discovery_group_entity.dart';
import 'package:mobile/features/group_discovery/domain/entities/group_discovery_failure.dart';
import 'package:mobile/features/group_discovery/domain/entities/group_genre_entity.dart';
import 'package:mobile/features/group_discovery/domain/entities/group_membership_status.dart';
import 'package:mobile/features/group_discovery/domain/entities/group_search_filters.dart';
import 'package:mobile/features/group_discovery/domain/entities/group_search_page_entity.dart';
import 'package:mobile/features/group_discovery/domain/repository/group_discovery_repository.dart';
import 'package:mobile/features/group_discovery/presentation/cubit/group_search_cubit.dart';
import 'package:mobile/features/group_discovery/presentation/cubit/group_search_state.dart';
import 'package:mocktail/mocktail.dart';

import '../../group_discovery_fixtures.dart';

class MockGroupDiscoveryRepository extends Mock
    implements GroupDiscoveryRepository {}

void main() {
  late MockGroupDiscoveryRepository repository;

  const genres = [GroupGenreEntity(id: 'g-1', name: 'Ficção')];
  const filters = GroupSearchFilters(genreId: 'g-1', minParticipants: 10);
  final g1 = searchGroup(1);
  final g2 = searchGroup(2);
  final g3 = searchGroup(3);

  void stubPage(
    int page,
    List<DiscoveryGroupEntity> items, {
    int total = 3,
    String search = '',
    GroupSearchFilters filters = GroupSearchFilters.empty,
  }) {
    when(
      () =>
          repository.searchGroups(page: page, search: search, filters: filters),
    ).thenAnswer(
      (_) async => Success(
        GroupSearchPageEntity(items: items, total: total, genres: genres),
      ),
    );
  }

  GroupSearchState loadedWith(
    List<DiscoveryGroupEntity> items, {
    int total = 3,
    int page = 1,
  }) => GroupSearchState(
    status: GroupSearchStatus.loaded,
    items: items,
    total: total,
    page: page,
    genres: genres,
  );

  setUpAll(() {
    registerFallbackValue(GroupSearchFilters.empty);
  });

  setUp(() {
    repository = MockGroupDiscoveryRepository();
  });

  GroupSearchCubit buildCubit() => GroupSearchCubit(repository: repository);

  group('load and pages', () {
    blocTest<GroupSearchCubit, GroupSearchState>(
      'loads the first page with the genre options',
      setUp: () => stubPage(1, [g1, g2]),
      build: buildCubit,
      act: (cubit) => cubit.load(),
      expect: () => [
        const GroupSearchState(),
        loadedWith([g1, g2]),
      ],
    );

    blocTest<GroupSearchCubit, GroupSearchState>(
      'appends the next page without repeating a group',
      setUp: () => stubPage(2, [g2, g3]),
      build: buildCubit,
      seed: () => loadedWith([g1, g2]),
      act: (cubit) => cubit.loadMore(),
      expect: () => [
        loadedWith([g1, g2]).copyWith(isLoadingMore: true),
        loadedWith([g1, g2, g3], page: 2),
      ],
      verify: (cubit) => expect(cubit.state.hasMore, isFalse),
    );

    blocTest<GroupSearchCubit, GroupSearchState>(
      'does not ask for more at the end of the list',
      build: buildCubit,
      seed: () => loadedWith([g1, g2, g3]),
      act: (cubit) => cubit.loadMore(),
      expect: () => <GroupSearchState>[],
      verify: (_) => verifyNever(
        () => repository.searchGroups(
          page: any(named: 'page'),
          search: any(named: 'search'),
          filters: any(named: 'filters'),
        ),
      ),
    );

    blocTest<GroupSearchCubit, GroupSearchState>(
      'flags a failed next page and retries it',
      setUp: () => when(
        () => repository.searchGroups(
          page: 2,
          search: '',
          filters: GroupSearchFilters.empty,
        ),
      ).thenAnswer((_) async => const Failure(GroupDiscoveryNetworkFailure())),
      build: buildCubit,
      seed: () => loadedWith([g1, g2]),
      act: (cubit) async {
        await cubit.loadMore();
        stubPage(2, [g3]);
        await cubit.retry();
      },
      expect: () => [
        loadedWith([g1, g2]).copyWith(isLoadingMore: true),
        loadedWith([g1, g2]).copyWith(loadMoreFailed: true),
        loadedWith([g1, g2]).copyWith(isLoadingMore: true),
        loadedWith([g1, g2, g3], page: 2),
      ],
    );

    blocTest<GroupSearchCubit, GroupSearchState>(
      'emits the first page failure and retries the first page',
      setUp: () =>
          when(
            () => repository.searchGroups(
              page: 1,
              search: '',
              filters: GroupSearchFilters.empty,
            ),
          ).thenAnswer(
            (_) async => const Failure(GroupDiscoveryInactiveAccountFailure()),
          ),
      build: buildCubit,
      act: (cubit) async {
        await cubit.load();
        stubPage(1, [g1]);
        await cubit.retry();
      },
      expect: () => [
        const GroupSearchState(),
        const GroupSearchState(
          status: GroupSearchStatus.error,
          failure: GroupDiscoveryInactiveAccountFailure(),
        ),
        const GroupSearchState(),
        loadedWith([g1]),
      ],
    );
  });

  group('search and filters', () {
    blocTest<GroupSearchCubit, GroupSearchState>(
      'searches the trimmed text from the first page, keeping the genres',
      setUp: () => stubPage(1, [g2], total: 1, search: 'dois'),
      build: buildCubit,
      seed: () => loadedWith([g1, g2]),
      act: (cubit) => cubit.search('  dois '),
      expect: () => [
        const GroupSearchState(query: 'dois', genres: genres),
        GroupSearchState(
          status: GroupSearchStatus.loaded,
          query: 'dois',
          items: [g2],
          total: 1,
          page: 1,
          genres: genres,
        ),
      ],
    );

    blocTest<GroupSearchCubit, GroupSearchState>(
      'ignores the same search again',
      build: buildCubit,
      seed: () => loadedWith([g1]),
      act: (cubit) => cubit.search('  '),
      expect: () => <GroupSearchState>[],
    );

    blocTest<GroupSearchCubit, GroupSearchState>(
      'applies the filters together with the current search',
      setUp: () =>
          stubPage(1, [g3], total: 1, search: 'três', filters: filters),
      build: buildCubit,
      seed: () => GroupSearchState(
        status: GroupSearchStatus.loaded,
        query: 'três',
        items: [g1],
        total: 1,
        page: 1,
        genres: genres,
      ),
      act: (cubit) => cubit.applyFilters(filters),
      verify: (cubit) {
        expect(cubit.state.filters, filters);
        expect(cubit.state.items, [g3]);
        expect(cubit.state.isFiltered, isTrue);
      },
    );

    test('only the latest search is applied', () async {
      final slow =
          Completer<Result<GroupSearchPageEntity, GroupDiscoveryFailure>>();
      when(
        () => repository.searchGroups(
          page: 1,
          search: 'um',
          filters: GroupSearchFilters.empty,
        ),
      ).thenAnswer((_) => slow.future);
      stubPage(1, [g2], total: 1, search: 'dois');
      final cubit = buildCubit();
      addTearDown(cubit.close);

      final first = cubit.search('um');
      await cubit.search('dois');
      slow.complete(
        const Success(GroupSearchPageEntity(items: [], total: 0, genres: [])),
      );
      await first;

      expect(cubit.state.query, 'dois');
      expect(cubit.state.items, [g2]);
    });
  });

  group('join request from the card', () {
    final rejected = searchGroup(2, membership: GroupMembershipStatus.rejected);

    blocTest<GroupSearchCubit, GroupSearchState>(
      'marks only that group as requested and signals the success',
      setUp: () => when(
        () => repository.requestJoin(g1.id),
      ).thenAnswer((_) async => const Success(null)),
      build: buildCubit,
      seed: () => loadedWith([g1, g2]),
      act: (cubit) => cubit.requestJoin(g1.id),
      expect: () => [
        loadedWith([g1, g2]).copyWith(requestingIds: {g1.id}),
        loadedWith([
          g1.copyWith(membershipStatus: GroupMembershipStatus.requested),
          g2,
        ]).copyWith(joinRequested: true),
      ],
    );

    blocTest<GroupSearchCubit, GroupSearchState>(
      'asks again for a rejected group',
      setUp: () => when(
        () => repository.requestJoin(rejected.id),
      ).thenAnswer((_) async => const Success(null)),
      build: buildCubit,
      seed: () => loadedWith([g1, rejected]),
      act: (cubit) => cubit.requestJoin(rejected.id),
      verify: (cubit) => expect(
        cubit.state.items.last.membershipStatus,
        GroupMembershipStatus.requested,
      ),
    );

    blocTest<GroupSearchCubit, GroupSearchState>(
      'keeps the card busy until the reload after "already requested"',
      setUp: () {
        when(() => repository.requestJoin(g1.id)).thenAnswer(
          (_) async => const Failure(GroupJoinAlreadyRequestedFailure()),
        );
        when(() => repository.getGroup(g1.id)).thenAnswer(
          (_) async => Success(
            g1.copyWith(membershipStatus: GroupMembershipStatus.member),
          ),
        );
      },
      build: buildCubit,
      seed: () => loadedWith([g1, g2]),
      act: (cubit) => cubit.requestJoin(g1.id),
      expect: () {
        final member = g1.copyWith(
          membershipStatus: GroupMembershipStatus.member,
        );
        const failure = GroupJoinAlreadyRequestedFailure();
        return [
          loadedWith([g1, g2]).copyWith(requestingIds: {g1.id}),
          loadedWith([
            g1,
            g2,
          ]).copyWith(requestingIds: {g1.id}, joinFailure: failure),
          loadedWith([
            member,
            g2,
          ]).copyWith(requestingIds: {g1.id}, joinFailure: failure),
          loadedWith([member, g2]).copyWith(joinFailure: failure),
        ];
      },
    );

    blocTest<GroupSearchCubit, GroupSearchState>(
      'drops a group that became unavailable',
      setUp: () => when(
        () => repository.requestJoin(g1.id),
      ).thenAnswer((_) async => const Failure(GroupUnavailableFailure())),
      build: buildCubit,
      seed: () => loadedWith([g1, g2]),
      act: (cubit) => cubit.requestJoin(g1.id),
      verify: (cubit) {
        expect(cubit.state.items, [g2]);
        expect(cubit.state.total, 2);
        expect(cubit.state.joinFailure, const GroupUnavailableFailure());
      },
    );

    blocTest<GroupSearchCubit, GroupSearchState>(
      'frees the card and signals any other failure',
      setUp: () => when(
        () => repository.requestJoin(g1.id),
      ).thenAnswer((_) async => const Failure(GroupJoinNoCoordinatorFailure())),
      build: buildCubit,
      seed: () => loadedWith([g1]),
      act: (cubit) => cubit.requestJoin(g1.id),
      expect: () => [
        loadedWith([g1]).copyWith(requestingIds: {g1.id}),
        loadedWith([
          g1,
        ]).copyWith(joinFailure: const GroupJoinNoCoordinatorFailure()),
      ],
    );

    for (final status in [
      GroupMembershipStatus.requested,
      GroupMembershipStatus.pending,
      GroupMembershipStatus.member,
    ]) {
      blocTest<GroupSearchCubit, GroupSearchState>(
        'does not ask when the reader is ${status.name}',
        build: buildCubit,
        seed: () => loadedWith([searchGroup(1, membership: status)]),
        act: (cubit) => cubit.requestJoin(searchGroupId(1)),
        expect: () => <GroupSearchState>[],
        verify: (_) => verifyNever(() => repository.requestJoin(any())),
      );
    }

    test('a double tap sends a single request', () async {
      final pending = Completer<Result<void, GroupDiscoveryFailure>>();
      when(
        () => repository.requestJoin(g1.id),
      ).thenAnswer((_) => pending.future);
      final cubit = buildCubit()..emit(loadedWith([g1]));
      addTearDown(cubit.close);

      final first = cubit.requestJoin(g1.id);
      final second = cubit.requestJoin(g1.id);
      pending.complete(const Success(null));
      await Future.wait([first, second]);

      verify(() => repository.requestJoin(g1.id)).called(1);
    });
  });

  group('refreshGroup', () {
    blocTest<GroupSearchCubit, GroupSearchState>(
      'replaces the group with its current status',
      setUp: () => when(() => repository.getGroup(g2.id)).thenAnswer(
        (_) async => Success(
          g2.copyWith(membershipStatus: GroupMembershipStatus.requested),
        ),
      ),
      build: buildCubit,
      seed: () => loadedWith([g1, g2]),
      act: (cubit) => cubit.refreshGroup(g2.id),
      expect: () => [
        loadedWith([
          g1,
          g2.copyWith(membershipStatus: GroupMembershipStatus.requested),
        ]),
      ],
    );

    blocTest<GroupSearchCubit, GroupSearchState>(
      'drops a group that is no longer available',
      setUp: () => when(
        () => repository.getGroup(g2.id),
      ).thenAnswer((_) async => const Failure(GroupUnavailableFailure())),
      build: buildCubit,
      seed: () => loadedWith([g1, g2]),
      act: (cubit) => cubit.refreshGroup(g2.id),
      expect: () => [
        loadedWith([g1], total: 2),
      ],
    );

    blocTest<GroupSearchCubit, GroupSearchState>(
      'keeps the list on other failures',
      setUp: () => when(
        () => repository.getGroup(g2.id),
      ).thenAnswer((_) async => const Failure(GroupDiscoveryNetworkFailure())),
      build: buildCubit,
      seed: () => loadedWith([g1, g2]),
      act: (cubit) => cubit.refreshGroup(g2.id),
      expect: () => <GroupSearchState>[],
    );
  });
}
