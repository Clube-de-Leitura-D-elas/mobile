import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/groups/domain/repository/group_repository.dart';
import 'package:mobile/features/groups/presentation/cubit/place_search_state.dart';

class PlaceSearchCubit extends Cubit<PlaceSearchState> {
  PlaceSearchCubit({
    required this.groupRepository,
    this.debounce = const Duration(milliseconds: 400),
  }) : super(const PlaceSearchState());

  /// Mesmo mínimo da function `search-places`.
  static const minQueryLength = 3;

  final GroupRepository groupRepository;
  final Duration debounce;

  Timer? _timer;
  int _lastRequest = 0;

  void search(String query) {
    _timer?.cancel();
    final trimmed = query.trim();

    if (trimmed.length < minQueryLength) {
      clear();
      return;
    }

    emit(state.copyWith(isLoading: true, hasError: false));
    _timer = Timer(debounce, () => _run(trimmed));
  }

  void clear() {
    _timer?.cancel();
    _lastRequest++;
    emit(const PlaceSearchState());
  }

  Future<void> _run(String query) async {
    final request = ++_lastRequest;
    final result = await groupRepository.searchPlaces(query);

    if (isClosed || request != _lastRequest) return;

    switch (result) {
      case Failure():
        emit(const PlaceSearchState(hasError: true));
      case Success(:final data):
        emit(PlaceSearchState(suggestions: data));
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
