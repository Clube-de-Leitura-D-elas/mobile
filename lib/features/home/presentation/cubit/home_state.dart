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
