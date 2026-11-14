import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/cities/domain/entities/city_scope.dart';
import 'package:mobile/features/group_discovery/domain/entities/discovery_group_entity.dart';
import 'package:mobile/features/group_discovery/domain/entities/group_discovery_failure.dart';
import 'package:mobile/features/group_discovery/domain/entities/group_membership_status.dart';
import 'package:mobile/features/group_discovery/domain/entities/group_search_filters.dart';
import 'package:mobile/features/group_discovery/domain/entities/group_search_page_entity.dart';
import 'package:mobile/features/group_discovery/domain/repository/group_discovery_repository.dart';
import 'package:mobile/features/group_discovery/presentation/cubit/group_search_cubit.dart';
import 'package:mobile/features/group_discovery/presentation/cubit/group_search_state.dart';
import 'package:mocktail/mocktail.dart';

import '../../../cities/cities_fixtures.dart';
import '../../group_discovery_fixtures.dart';

class MockGroupDiscoveryRepository extends Mock
    implements GroupDiscoveryRepository {}

void main() {
  late MockGroupDiscoveryRepository repository;
  late MockDiscoveryCitiesRepository citiesRepository;

  const filters = GroupSearchFilters(minParticipants: 10);
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
      (_) async => Success(GroupSearchPageEntity(items: items, total: total)),
    );
  }

  GroupSearchState loadedWith(
    List<DiscoveryGroupEntity> items, {
    int total = 3,
    int page = 1,
    bool reachedEnd = false,
  }) => GroupSearchState(
    status: GroupSearchStatus.loaded,
    items: items,
    total: total,
    page: page,
    reachedEnd: reachedEnd,
  );

  /// Página cheia: grupos [first] a [first] + 19.
  List<DiscoveryGroupEntity> fullPage(int first) => [
    for (var i = 0; i < GroupDiscoveryRepository.pageSize; i++)
      searchGroup(first + i),
  ];

  setUpAll(() {
    registerFallbackValue(GroupSearchFilters.empty);
  });

  setUp(() {
    repository = MockGroupDiscoveryRepository();
    citiesRepository = MockDiscoveryCitiesRepository();
    // Sem a lista de cidades, a busca de antes do filtro.
    stubCitiesFailure(citiesRepository);
  });

  GroupSearchCubit buildCubit() => GroupSearchCubit(
    repository: repository,
    citiesRepository: citiesRepository,
  );

  group('load and pages', () {
    blocTest<GroupSearchCubit, GroupSearchState>(
      'loads the first page',
      setUp: () => stubPage(1, fullPage(1), total: 45),
      build: buildCubit,
      act: (cubit) => cubit.load(),
      expect: () => [
        const GroupSearchState(),
        loadedWith(fullPage(1), total: 45),
      ],
      verify: (cubit) => expect(cubit.state.hasMore, isTrue),
    );

    blocTest<GroupSearchCubit, GroupSearchState>(
      'ends the list when the first page is not full',
      setUp: () => stubPage(1, [g1, g2]),
      build: buildCubit,
      act: (cubit) => cubit.load(),
      verify: (cubit) {
        expect(cubit.state.reachedEnd, isTrue);
        expect(cubit.state.hasMore, isFalse);
      },
    );

    blocTest<GroupSearchCubit, GroupSearchState>(
      'appends the next page without repeating a group',
      setUp: () => stubPage(2, [...fullPage(20)], total: 45),
      build: buildCubit,
      seed: () => loadedWith(fullPage(1), total: 45),
      act: (cubit) => cubit.loadMore(),
      verify: (cubit) {
        expect(cubit.state.items, [...fullPage(1), ...fullPage(21).take(19)]);
        expect(cubit.state.page, 2);
        expect(cubit.state.hasMore, isTrue);
      },
    );

    blocTest<GroupSearchCubit, GroupSearchState>(
      'ends the list on an empty page even when the total says otherwise',
      setUp: () => stubPage(2, [], total: 45),
      build: buildCubit,
      seed: () => loadedWith(fullPage(1), total: 45),
      act: (cubit) => cubit.loadMore(),
      verify: (cubit) {
        expect(cubit.state.items, hasLength(20));
        expect(cubit.state.hasMore, isFalse);
      },
    );

    blocTest<GroupSearchCubit, GroupSearchState>(
      'ends the list on a page made only of repeated groups',
      setUp: () => stubPage(2, [g1, g2], total: 45),
      build: buildCubit,
      seed: () => loadedWith(fullPage(1), total: 45),
      act: (cubit) async {
        await cubit.loadMore();
        await cubit.loadMore();
      },
      verify: (cubit) {
        expect(cubit.state.hasMore, isFalse);
        verify(
          () => repository.searchGroups(
            page: any(named: 'page'),
            search: any(named: 'search'),
            filters: any(named: 'filters'),
          ),
        ).called(1);
      },
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
        loadedWith([g1, g2, g3], page: 2, reachedEnd: true),
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
        loadedWith([g1], reachedEnd: true),
      ],
    );

    test('drops an old next page once a new search starts', () async {
      final slowPage =
          Completer<Result<GroupSearchPageEntity, GroupDiscoveryFailure>>();
      when(
        () => repository.searchGroups(
          page: 2,
          search: '',
          filters: GroupSearchFilters.empty,
        ),
      ).thenAnswer((_) => slowPage.future);
      stubPage(1, [g3], total: 1, search: 'três');
      final cubit = buildCubit()..emit(loadedWith(fullPage(1), total: 45));
      addTearDown(cubit.close);

      final oldPage = cubit.loadMore();
      await cubit.search('três');
      slowPage.complete(
        Success(GroupSearchPageEntity(items: fullPage(21), total: 45)),
      );
      await oldPage;

      expect(cubit.state.query, 'três');
      expect(cubit.state.items, [g3]);
    });
  });

  group('search and filters', () {
    blocTest<GroupSearchCubit, GroupSearchState>(
      'searches the trimmed text from the first page',
      setUp: () => stubPage(1, [g2], total: 1, search: 'dois'),
      build: buildCubit,
      seed: () => loadedWith([g1, g2]),
      act: (cubit) => cubit.search('  dois '),
      expect: () => [
        const GroupSearchState(query: 'dois'),
        GroupSearchState(
          status: GroupSearchStatus.loaded,
          query: 'dois',
          items: [g2],
          total: 1,
          page: 1,
          reachedEnd: true,
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
      slow.complete(const Success(GroupSearchPageEntity(items: [], total: 0)));
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

    test('a reload started before the request does not undo it', () async {
      final staleRead =
          Completer<Result<DiscoveryGroupEntity, GroupDiscoveryFailure>>();
      when(
        () => repository.getGroup(g1.id),
      ).thenAnswer((_) => staleRead.future);
      when(
        () => repository.requestJoin(g1.id),
      ).thenAnswer((_) async => const Success(null));
      final cubit = buildCubit()..emit(loadedWith([g1, g2]));
      addTearDown(cubit.close);

      final reload = cubit.refreshGroup(g1.id);
      await cubit.requestJoin(g1.id);
      staleRead.complete(Success(g1));
      await reload;

      expect(
        cubit.state.items.first.membershipStatus,
        GroupMembershipStatus.requested,
      );
    });

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

  group('city filter', () {
    void stubCityPage(
      CityScope? city,
      List<DiscoveryGroupEntity> items, {
      String search = '',
      GroupSearchFilters filters = GroupSearchFilters.empty,
      int page = 1,
    }) {
      when(
        () => repository.searchGroups(
          page: page,
          search: search,
          filters: filters,
          city: city,
        ),
      ).thenAnswer(
        (_) async => Success(GroupSearchPageEntity(items: items, total: 45)),
      );
    }

    Matcher stateWith({
      required GroupSearchStatus status,
      required bool citiesAvailable,
      GroupSearchFilters filters = GroupSearchFilters.empty,
      List<DiscoveryGroupEntity> items = const [],
    }) => isA<GroupSearchState>()
        .having((s) => s.status, 'status', status)
        .having((s) => s.citiesAvailable, 'citiesAvailable', citiesAvailable)
        .having(
          (s) => s.cities,
          'cities',
          citiesAvailable ? const [portoAlegre, saoPaulo] : isEmpty,
        )
        .having((s) => s.filters, 'filters', filters)
        .having((s) => s.items, 'items', items);

    blocTest<GroupSearchCubit, GroupSearchState>(
      'emits loading, then the cities, then the groups of every city',
      setUp: () {
        stubCities(citiesRepository);
        stubCityPage(CityScope.all, [g1]);
      },
      build: buildCubit,
      act: (cubit) => cubit.load(),
      expect: () => [
        stateWith(status: GroupSearchStatus.loading, citiesAvailable: false),
        stateWith(status: GroupSearchStatus.loading, citiesAvailable: true),
        stateWith(
          status: GroupSearchStatus.loaded,
          citiesAvailable: true,
          items: [g1],
        ),
      ],
    );

    blocTest<GroupSearchCubit, GroupSearchState>(
      'without the cities emits loading and the groups, with no city list',
      setUp: () => stubPage(1, [g1]),
      build: buildCubit,
      act: (cubit) => cubit.load(),
      expect: () => [
        stateWith(status: GroupSearchStatus.loading, citiesAvailable: false),
        stateWith(
          status: GroupSearchStatus.loaded,
          citiesAvailable: false,
          items: [g1],
        ),
      ],
    );

    blocTest<GroupSearchCubit, GroupSearchState>(
      'changing the city keeps the city list while it reloads',
      setUp: () {
        stubCities(citiesRepository);
        stubCityPage(CityScope.all, [g1]);
        stubCityPage(CityScope.only(saoPaulo.id), [
          g2,
        ], filters: const GroupSearchFilters(city: saoPaulo));
      },
      build: buildCubit,
      act: (cubit) async {
        await cubit.load();
        await cubit.applyFilters(const GroupSearchFilters(city: saoPaulo));
      },
      skip: 3,
      expect: () => [
        stateWith(
          status: GroupSearchStatus.loading,
          citiesAvailable: true,
          filters: const GroupSearchFilters(city: saoPaulo),
        ),
        stateWith(
          status: GroupSearchStatus.loaded,
          citiesAvailable: true,
          filters: const GroupSearchFilters(city: saoPaulo),
          items: [g2],
        ),
      ],
    );

    test('waits for the cities and searches every city by default', () async {
      stubCities(citiesRepository);
      stubCityPage(CityScope.all, [g1]);
      final cubit = buildCubit();
      addTearDown(cubit.close);

      await cubit.load();

      expect(cubit.state.citiesAvailable, isTrue);
      expect(cubit.state.cities, const [portoAlegre, saoPaulo]);
      expect(cubit.state.filters.city, isNull);
      expect(cubit.state.isFiltered, isFalse);
      expect(cubit.state.items, [g1]);
      verify(
        () => repository.searchGroups(
          page: 1,
          search: '',
          filters: GroupSearchFilters.empty,
          city: CityScope.all,
        ),
      ).called(1);
      verifyNever(
        () => repository.searchGroups(
          page: any(named: 'page'),
          search: any(named: 'search'),
          filters: any(named: 'filters'),
        ),
      );
    });

    test('a search typed while the cities load also waits for them', () async {
      final cities = Completer<void>();
      when(citiesRepository.getCities).thenAnswer((_) async {
        await cities.future;
        return Success(discoveryCities);
      });
      stubCityPage(CityScope.all, [g1]);
      stubCityPage(CityScope.all, [g2], search: 'dois');
      final cubit = buildCubit();
      addTearDown(cubit.close);

      final load = cubit.load();
      final search = cubit.search('dois');
      cities.complete();
      await Future.wait([load, search]);

      expect(cubit.state.query, 'dois');
      expect(cubit.state.items, [g2]);
      verify(
        () => repository.searchGroups(
          page: 1,
          search: 'dois',
          filters: GroupSearchFilters.empty,
          city: CityScope.all,
        ),
      ).called(1);
    });

    test('a chosen city goes as its cityId, on the next pages too', () async {
      stubCities(citiesRepository);
      stubCityPage(CityScope.all, fullPage(1));
      const inSaoPaulo = GroupSearchFilters(city: saoPaulo);
      final scope = CityScope.only(saoPaulo.id);
      stubCityPage(scope, fullPage(1), filters: inSaoPaulo);
      stubCityPage(scope, fullPage(21), filters: inSaoPaulo, page: 2);
      final cubit = buildCubit();
      addTearDown(cubit.close);
      await cubit.load();

      await cubit.applyFilters(inSaoPaulo);
      await cubit.loadMore();

      expect(cubit.state.filters, inSaoPaulo);
      expect(cubit.state.isFiltered, isTrue);
      expect(cubit.state.page, 2);
      verify(
        () => repository.searchGroups(
          page: 2,
          search: '',
          filters: inSaoPaulo,
          city: scope,
        ),
      ).called(1);
    });

    test('without the city list the search sends no cityId; only load() tries '
        'the list again', () async {
      stubPage(1, [g1]);
      stubPage(1, [g2], search: 'dois');
      final cubit = buildCubit();
      addTearDown(cubit.close);

      await cubit.load();
      expect(cubit.state.citiesAvailable, isFalse);
      expect(cubit.state.cityScope, isNull);
      expect(cubit.state.items, [g1]);

      await cubit.search('dois');
      verify(citiesRepository.getCities).called(1);

      stubCities(citiesRepository);
      stubCityPage(CityScope.all, [g2], search: 'dois');
      await cubit.load();
      verify(citiesRepository.getCities).called(1);
      expect(cubit.state.citiesAvailable, isTrue);
    });

    test('loads the cities only once', () async {
      stubCities(citiesRepository);
      stubCityPage(CityScope.all, [g1]);
      final cubit = buildCubit();
      addTearDown(cubit.close);

      await cubit.load();
      await cubit.load();

      verify(citiesRepository.getCities).called(1);
    });
  });
}
