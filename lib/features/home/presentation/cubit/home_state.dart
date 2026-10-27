import 'package:equatable/equatable.dart';
import 'package:mobile/features/groups/domain/entities/group_entity.dart';

enum HomeStatus { initial, loading, loaded, error }

enum HomeEmptyKind { noGroups, noSearchResults, noPendingTasks }

class HomeState extends Equatable {
  final HomeStatus status;
  final List<GroupEntity> groups;
  final Set<String> expandedGroupIds;
  final String searchQuery;
  final String? errorMessage;

  const HomeState({
    this.status = HomeStatus.initial,
    this.groups = const [],
    this.expandedGroupIds = const {},
    this.searchQuery = '',
    this.errorMessage,
  });

  HomeState copyWith({
    HomeStatus? status,
    List<GroupEntity>? groups,
    Set<String>? expandedGroupIds,
    String? searchQuery,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      groups: groups ?? this.groups,
      expandedGroupIds: expandedGroupIds ?? this.expandedGroupIds,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool isGroupExpanded(String groupId) => expandedGroupIds.contains(groupId);

  /// Grupos em que a anfitriã ainda tem tarefas a concluir no próximo encontro.
  List<GroupEntity> get pendingTasksGroups => groups.where((group) {
    final meeting = group.nextMeeting;
    return meeting != null &&
        meeting.id != null &&
        meeting.canManageTasks &&
        meeting.tasksDone < meeting.tasksTotal;
  }).toList();

  bool get hasPendingTasks => pendingTasksGroups.isNotEmpty;

  List<GroupEntity> filteredGroups(String Function(GroupEntity) nameOf) {
    final query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) return groups;
    return groups
        .where((g) => nameOf(g).toLowerCase().contains(query))
        .toList();
  }

  HomeEmptyKind? emptyKindFor(List<GroupEntity> visibleGroups) {
    if (visibleGroups.isNotEmpty) return null;
    if (groups.isNotEmpty) return HomeEmptyKind.noSearchResults;
    return HomeEmptyKind.noGroups;
  }

  @override
  List<Object?> get props => [
    status,
    groups,
    expandedGroupIds,
    searchQuery,
    errorMessage,
  ];
}
