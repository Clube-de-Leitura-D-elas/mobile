import 'package:equatable/equatable.dart';
import 'package:mobile/features/groups/domain/entities/group_entity.dart';

enum HomeStatus { initial, loading, loaded, error }

class HomeState extends Equatable {
  final HomeStatus status;
  final List<GroupEntity> groups;
  final Set<String> expandedGroupIds;
  final int selectedFilterIndex;
  final String searchQuery;
  final String? errorMessage;

  const HomeState({
    this.status = HomeStatus.initial,
    this.groups = const [],
    this.expandedGroupIds = const {},
    this.selectedFilterIndex = 0,
    this.searchQuery = '',
    this.errorMessage,
  });

  HomeState copyWith({
    HomeStatus? status,
    List<GroupEntity>? groups,
    Set<String>? expandedGroupIds,
    int? selectedFilterIndex,
    String? searchQuery,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      groups: groups ?? this.groups,
      expandedGroupIds: expandedGroupIds ?? this.expandedGroupIds,
      selectedFilterIndex: selectedFilterIndex ?? this.selectedFilterIndex,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool isGroupExpanded(String groupId) => expandedGroupIds.contains(groupId);

  int get unansweredCount => groups.where((g) => g.hasPendingResponse).length;

  List<GroupEntity> get filteredGroups {
    return groups.where((group) {
      if (selectedFilterIndex == 1 && !group.hasPendingResponse) {
        return false;
      }
      if (selectedFilterIndex == 2 &&
          (group.nextMeeting == null || group.hasPendingResponse)) {
        return false;
      }

      final query = searchQuery.trim().toLowerCase();
      if (query.isEmpty) return true;

      final matchesCity = group.cityState.toLowerCase().contains(query);
      final matchesNumber =
          group.number.toString().contains(query) ||
          'grupo ${group.number}'.toLowerCase().contains(query);
      final matchesBook =
          group.nextMeeting?.bookTitle.toLowerCase().contains(query) ?? false;
      final matchesHost =
          group.nextMeeting?.hostName.toLowerCase().contains(query) ?? false;
      final matchesLocation =
          group.nextMeeting?.location.toLowerCase().contains(query) ?? false;

      return matchesCity ||
          matchesNumber ||
          matchesBook ||
          matchesHost ||
          matchesLocation;
    }).toList();
  }

  @override
  List<Object?> get props => [
        status,
        groups,
        expandedGroupIds,
        selectedFilterIndex,
        searchQuery,
        errorMessage,
      ];
}
