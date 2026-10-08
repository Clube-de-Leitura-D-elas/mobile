import 'package:equatable/equatable.dart';
import 'package:mobile/features/groups/domain/entities/group_entity.dart';

enum HomeStatus { initial, loading, loaded, error }

enum HomeFilter { all, unanswered, answered }

enum HomeEmptyKind { noGroups, noSearchResults, noUnanswered, noAnswered }

class HomeState extends Equatable {
  final HomeStatus status;
  final List<GroupEntity> groups;
  final Set<String> expandedGroupIds;
  final HomeFilter filter;
  final String searchQuery;
  final String? errorMessage;

  const HomeState({
    this.status = HomeStatus.initial,
    this.groups = const [],
    this.expandedGroupIds = const {},
    this.filter = HomeFilter.all,
    this.searchQuery = '',
    this.errorMessage,
  });

  HomeState copyWith({
    HomeStatus? status,
    List<GroupEntity>? groups,
    Set<String>? expandedGroupIds,
    HomeFilter? filter,
    String? searchQuery,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      groups: groups ?? this.groups,
      expandedGroupIds: expandedGroupIds ?? this.expandedGroupIds,
      filter: filter ?? this.filter,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool isGroupExpanded(String groupId) => expandedGroupIds.contains(groupId);

  int get selectedFilterIndex => filter.index;

  /// Total de grupos pendentes, independente da busca.
  int get unansweredCount => groups.where((g) => g.hasPendingResponse).length;

  List<GroupEntity> _groupsByFilter() => switch (filter) {
    HomeFilter.all => groups,
    HomeFilter.unanswered => groups.where((g) => g.hasPendingResponse).toList(),
    HomeFilter.answered =>
      groups.where((g) => g.hasAnsweredNextMeeting).toList(),
  };

  List<GroupEntity> filteredGroups(String Function(GroupEntity) nameOf) {
    final query = searchQuery.trim().toLowerCase();
    final byFilter = _groupsByFilter();
    if (query.isEmpty) return byFilter;
    return byFilter
        .where((g) => nameOf(g).toLowerCase().contains(query))
        .toList();
  }

  HomeEmptyKind? emptyKindFor(List<GroupEntity> visibleGroups) {
    if (visibleGroups.isNotEmpty) return null;
    if (_groupsByFilter().isNotEmpty) return HomeEmptyKind.noSearchResults;
    return switch (filter) {
      HomeFilter.all => HomeEmptyKind.noGroups,
      HomeFilter.unanswered => HomeEmptyKind.noUnanswered,
      HomeFilter.answered => HomeEmptyKind.noAnswered,
    };
  }

  @override
  List<Object?> get props => [
    status,
    groups,
    expandedGroupIds,
    filter,
    searchQuery,
    errorMessage,
  ];
}
