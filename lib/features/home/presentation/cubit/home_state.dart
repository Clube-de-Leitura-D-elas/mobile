import 'package:equatable/equatable.dart';
import 'package:mobile/features/groups/domain/entities/group_entity.dart';
import 'package:mobile/features/groups/domain/entities/group_meeting.dart';

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

  /// Uma entrada por encontro em que a usuária ainda tem tarefas a concluir,
  /// com o encontro pendente no lugar de `nextMeeting`.
  List<GroupEntity> get pendingTasksGroups => [
    for (final group in groups)
      for (final meeting in _pendingMeetingsOf(group))
        group.copyWith(nextMeeting: meeting),
  ];

  // Backends anteriores a `pending_meetings` só mandam as tarefas no
  // `next_meeting`. Ids repetidos virariam cards com a mesma key.
  static List<GroupMeeting> _pendingMeetingsOf(GroupEntity group) {
    final seenIds = <String>{};
    return [...group.pendingMeetings, ?group.nextMeeting]
        .where(
          (meeting) => _hasPendingTasks(meeting) && seenIds.add(meeting.id!),
        )
        .toList();
  }

  static bool _hasPendingTasks(GroupMeeting meeting) =>
      meeting.id != null &&
      meeting.canManageTasks &&
      meeting.tasksDone < meeting.tasksTotal;

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
