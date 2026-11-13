import 'package:equatable/equatable.dart';
import 'package:mobile/features/group_discovery/domain/entities/discovery_group_entity.dart';
import 'package:mobile/features/group_discovery/domain/entities/group_discovery_failure.dart';
import 'package:mobile/features/group_discovery/domain/entities/group_genre_entity.dart';
import 'package:mobile/features/group_discovery/domain/entities/group_search_filters.dart';

enum GroupSearchStatus { loading, loaded, error }

class GroupSearchState extends Equatable {
  final GroupSearchStatus status;
  final String query;
  final GroupSearchFilters filters;
  final List<DiscoveryGroupEntity> items;
  final int total;
  final int page;
  final List<GroupGenreEntity> genres;
  final bool isLoadingMore;
  final bool loadMoreFailed;

  /// A última página veio vazia ou incompleta. Encerra a lista mesmo que
  /// [total] diga que falta: inclusões e remoções entre páginas deslocam o
  /// offset e o total deixa de bater com o que foi carregado.
  final bool reachedEnd;

  /// Por que a primeira página não carregou, quando [status] é `error`.
  final GroupDiscoveryFailure? failure;

  /// Grupos com pedido de entrada em andamento.
  final Set<String> requestingIds;

  /// Retorno do último pedido de entrada, para um aviso único na tela; a
  /// tela limpa com `clearJoinFeedback` depois de mostrar.
  final bool joinRequested;
  final GroupDiscoveryFailure? joinFailure;

  const GroupSearchState({
    this.status = GroupSearchStatus.loading,
    this.query = '',
    this.filters = GroupSearchFilters.empty,
    this.items = const [],
    this.total = 0,
    this.page = 0,
    this.genres = const [],
    this.isLoadingMore = false,
    this.loadMoreFailed = false,
    this.reachedEnd = false,
    this.failure,
    this.requestingIds = const {},
    this.joinRequested = false,
    this.joinFailure,
  });

  bool get hasMore => !reachedEnd && items.length < total;

  bool get isFiltered => query.isNotEmpty || !filters.isEmpty;

  bool get hasJoinFeedback => joinRequested || joinFailure != null;

  GroupSearchState copyWith({
    List<DiscoveryGroupEntity>? items,
    int? total,
    int? page,
    List<GroupGenreEntity>? genres,
    bool? isLoadingMore,
    bool? loadMoreFailed,
    bool? reachedEnd,
    Set<String>? requestingIds,
    bool? joinRequested,
    GroupDiscoveryFailure? joinFailure,
    bool clearJoinFailure = false,
  }) {
    return GroupSearchState(
      status: status,
      query: query,
      filters: filters,
      items: items ?? this.items,
      total: total ?? this.total,
      page: page ?? this.page,
      genres: genres ?? this.genres,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreFailed: loadMoreFailed ?? this.loadMoreFailed,
      reachedEnd: reachedEnd ?? this.reachedEnd,
      failure: failure,
      requestingIds: requestingIds ?? this.requestingIds,
      joinRequested: joinRequested ?? this.joinRequested,
      joinFailure: clearJoinFailure ? null : joinFailure ?? this.joinFailure,
    );
  }

  @override
  List<Object?> get props => [
    status,
    query,
    filters,
    items,
    total,
    page,
    genres,
    isLoadingMore,
    loadMoreFailed,
    reachedEnd,
    failure,
    requestingIds,
    joinRequested,
    joinFailure,
  ];
}
