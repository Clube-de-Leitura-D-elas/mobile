import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/groups/domain/entities/group_failure.dart';
import 'package:mobile/features/groups/domain/entities/place_suggestion_entity.dart';
import 'package:mobile/features/groups/domain/repository/group_repository.dart';
import 'package:mobile/features/groups/presentation/cubit/place_search_cubit.dart';
import 'package:mobile/features/groups/presentation/cubit/place_search_state.dart';
import 'package:mocktail/mocktail.dart';

class MockGroupRepository extends Mock implements GroupRepository {}

void main() {
  late MockGroupRepository repository;

  const place = PlaceSuggestionEntity(
    googlePlaceId: 'place-1',
    name: 'Café Paris',
    address: 'R. A, 10',
  );

  setUp(() {
    repository = MockGroupRepository();
  });

  PlaceSearchCubit buildCubit({Duration debounce = Duration.zero}) =>
      PlaceSearchCubit(groupRepository: repository, debounce: debounce);

  blocTest<PlaceSearchCubit, PlaceSearchState>(
    'given a query, when the debounce ends, then emits the suggestions',
    build: () {
      when(
        () => repository.searchPlaces('café'),
      ).thenAnswer((_) async => const Success([place]));
      return buildCubit();
    },
    act: (cubit) => cubit.search('café'),
    wait: const Duration(milliseconds: 10),
    expect: () => const [
      PlaceSearchState(isLoading: true),
      PlaceSearchState(suggestions: [place]),
    ],
  );

  blocTest<PlaceSearchCubit, PlaceSearchState>(
    'given the search fails, when searching, then emits an error',
    build: () {
      when(
        () => repository.searchPlaces('café'),
      ).thenAnswer((_) async => const Failure(PlaceSearchFailure()));
      return buildCubit();
    },
    act: (cubit) => cubit.search('café'),
    wait: const Duration(milliseconds: 10),
    expect: () => const [
      PlaceSearchState(isLoading: true),
      PlaceSearchState(hasError: true),
    ],
  );

  blocTest<PlaceSearchCubit, PlaceSearchState>(
    'given fast typing, when the debounce ends, then searches only the last text',
    build: () {
      when(
        () => repository.searchPlaces(any()),
      ).thenAnswer((_) async => const Success([place]));
      return buildCubit(debounce: const Duration(milliseconds: 50));
    },
    act: (cubit) {
      cubit
        ..search('caf')
        ..search('café');
    },
    wait: const Duration(milliseconds: 100),
    verify: (_) {
      verifyNever(() => repository.searchPlaces('caf'));
      verify(() => repository.searchPlaces('café')).called(1);
    },
  );

  blocTest<PlaceSearchCubit, PlaceSearchState>(
    'given fewer than 3 letters, when searching, then does not call the backend',
    build: buildCubit,
    act: (cubit) => cubit.search(' ca '),
    wait: const Duration(milliseconds: 10),
    expect: () => const [PlaceSearchState()],
    verify: (_) => verifyNever(() => repository.searchPlaces(any())),
  );

  blocTest<PlaceSearchCubit, PlaceSearchState>(
    'given a place was chosen, when an old response arrives, then ignores it',
    build: () {
      final response =
          Completer<Result<List<PlaceSuggestionEntity>, GroupFailure>>();
      when(
        () => repository.searchPlaces('café'),
      ).thenAnswer((_) => response.future);
      addTearDown(() {
        if (!response.isCompleted) response.complete(const Success([place]));
      });
      return buildCubit();
    },
    act: (cubit) async {
      cubit.search('café');
      await Future<void>.delayed(Duration.zero);
      cubit.clear();
    },
    wait: const Duration(milliseconds: 10),
    expect: () => const [PlaceSearchState(isLoading: true), PlaceSearchState()],
  );
}
