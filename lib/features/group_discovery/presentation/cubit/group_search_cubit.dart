import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/group_discovery/domain/entities/discovery_group_entity.dart';
import 'package:mobile/features/group_discovery/domain/entities/group_discovery_failure.dart';
import 'package:mobile/features/group_discovery/domain/entities/group_membership_status.dart';
import 'package:mobile/features/group_discovery/domain/entities/group_search_filters.dart';
import 'package:mobile/features/group_discovery/domain/repository/group_discovery_repository.dart';
import 'package:mobile/features/group_discovery/presentation/cubit/group_search_state.dart';

class GroupSearchCubit extends Cubit<GroupSearchState> {
  final GroupDiscoveryRepository repository;

  /// Só a resposta da busca mais recente é aplicada.
  int _request = 0;

  GroupSearchCubit({required this.repository})
    : super(const GroupSearchState());

  Future<void> load() => _reload(query: state.query, filters: state.filters);

  Future<void> search(String query) {
    final trimmed = query.trim();
    if (trimmed == state.query && state.status != GroupSearchStatus.error) {
      return Future<void>.value();
    }
    return _reload(query: trimmed, filters: state.filters);
  }

  Future<void> applyFilters(GroupSearchFilters filters) {
    if (filters == state.filters && state.status != GroupSearchStatus.error) {
      return Future<void>.value();
    }
    return _reload(query: state.query, filters: filters);
  }

  Future<void> retry() =>
      state.status == GroupSearchStatus.error ? load() : loadMore();

  Future<void> loadMore() async {
    if (state.status != GroupSearchStatus.loaded ||
        !state.hasMore ||
        state.isLoadingMore) {
      return;
    }
    final request = _request;
    emit(state.copyWith(isLoadingMore: true, loadMoreFailed: false));

    final nextPage = state.page + 1;
    final result = await repository.searchGroups(
      page: nextPage,
      search: state.query,
      filters: state.filters,
    );
    if (isClosed || request != _request) return;

    switch (result) {
      case Failure():
        emit(state.copyWith(isLoadingMore: false, loadMoreFailed: true));
      case Success(:final data):
        // Grupo novo desloca as páginas e pode repetir item já carregado.
        final loadedIds = {for (final item in state.items) item.id};
        emit(
          state.copyWith(
            items: [
              ...state.items,
              ...data.items.where((item) => !loadedIds.contains(item.id)),
            ],
            total: data.total,
            page: nextPage,
            genres: data.genres,
            isLoadingMore: false,
            reachedEnd: _isLastPage(data.items.length),
          ),
        );
    }
  }

  Future<void> requestJoin(String groupId) async {
    if (isClosed) return;
    final group = _find(groupId);
    if (group == null ||
        !group.canRequestJoin ||
        state.requestingIds.contains(groupId)) {
      return;
    }

    emit(
      state.copyWith(
        requestingIds: {...state.requestingIds, groupId},
        joinRequested: false,
        clearJoinFailure: true,
      ),
    );

    final result = await repository.requestJoin(groupId);
    if (isClosed) return;

    switch (result) {
      case Success():
        // O item pode ter mudado durante o pedido (releitura ao voltar).
        final current = _find(groupId);
        emit(
          state.copyWith(
            items: current == null
                ? null
                : _replace(
                    current.copyWith(
                      membershipStatus: GroupMembershipStatus.requested,
                    ),
                  ),
            requestingIds: _without(groupId),
            joinRequested: true,
          ),
        );
      case Failure(failure: final GroupUnavailableFailure failure):
        final stillListed = _find(groupId) != null;
        emit(
          state.copyWith(
            items: stillListed ? _remove(groupId) : null,
            total: stillListed ? state.total - 1 : null,
            requestingIds: _without(groupId),
            joinFailure: failure,
          ),
        );
      case Failure(:final failure)
          when failure is GroupJoinAlreadyRequestedFailure:
        // O card segue ocupado até o status real chegar.
        emit(state.copyWith(joinFailure: failure));
        await refreshGroup(groupId);
        if (isClosed) return;
        emit(state.copyWith(requestingIds: _without(groupId)));
      case Failure(:final failure):
        emit(
          state.copyWith(
            requestingIds: _without(groupId),
            joinFailure: failure,
          ),
        );
    }
  }

  /// Relê um grupo da lista, por exemplo ao voltar da tela dele, onde o
  /// status pode ter mudado. Indisponível sai da lista; outros erros mantêm o
  /// que está na tela.
  Future<void> refreshGroup(String groupId) async {
    if (_find(groupId) == null) return;
    final result = await repository.getGroup(groupId);
    if (isClosed || _find(groupId) == null) return;

    switch (result) {
      case Success(:final data):
        emit(state.copyWith(items: _replace(data)));
      case Failure(failure: GroupUnavailableFailure()):
        emit(state.copyWith(items: _remove(groupId), total: state.total - 1));
      case Failure():
        return;
    }
  }

  void clearJoinFeedback() {
    emit(state.copyWith(joinRequested: false, clearJoinFailure: true));
  }

  Future<void> _reload({
    required String query,
    required GroupSearchFilters filters,
  }) async {
    final request = ++_request;
    emit(
      GroupSearchState(
        query: query,
        filters: filters,
        genres: state.genres,
        requestingIds: state.requestingIds,
      ),
    );

    final result = await repository.searchGroups(
      page: 1,
      search: query,
      filters: filters,
    );
    if (isClosed || request != _request) return;

    switch (result) {
      case Failure(:final failure):
        emit(
          GroupSearchState(
            status: GroupSearchStatus.error,
            query: query,
            filters: filters,
            genres: state.genres,
            failure: failure,
            requestingIds: state.requestingIds,
          ),
        );
      case Success(:final data):
        emit(
          GroupSearchState(
            status: GroupSearchStatus.loaded,
            query: query,
            filters: filters,
            items: data.items,
            total: data.total,
            page: 1,
            genres: data.genres,
            reachedEnd: _isLastPage(data.items.length),
            requestingIds: state.requestingIds,
          ),
        );
    }
  }

  static bool _isLastPage(int received) =>
      received < GroupDiscoveryRepository.pageSize;

  DiscoveryGroupEntity? _find(String groupId) {
    for (final item in state.items) {
      if (item.id == groupId) return item;
    }
    return null;
  }

  List<DiscoveryGroupEntity> _replace(DiscoveryGroupEntity group) => [
    for (final item in state.items) item.id == group.id ? group : item,
  ];

  List<DiscoveryGroupEntity> _remove(String groupId) => [
    for (final item in state.items)
      if (item.id != groupId) item,
  ];

  Set<String> _without(String groupId) => {
    for (final id in state.requestingIds)
      if (id != groupId) id,
  };
}
