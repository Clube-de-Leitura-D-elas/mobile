import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/groups/data/mock_groups.dart';
import 'package:mobile/features/groups/domain/entities/group_entity.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeState());

  void loadGroups({List<GroupEntity>? initialGroups}) {
    emit(state.copyWith(status: HomeStatus.loading));

    final groups = initialGroups ?? MockGroups.defaultGroups;
    // In Figma node 644:1225, Grupo 1 and Grupo 12 are expanded; Grupo 27 is collapsed.
    final initialExpanded = groups
        .where((g) => g.id != '27')
        .map((g) => g.id)
        .toSet();

    emit(state.copyWith(
      status: HomeStatus.loaded,
      groups: groups,
      expandedGroupIds: initialExpanded,
    ));
  }

  void toggleCardExpansion(String groupId) {
    final currentExpanded = Set<String>.from(state.expandedGroupIds);
    if (currentExpanded.contains(groupId)) {
      currentExpanded.remove(groupId);
    } else {
      currentExpanded.add(groupId);
    }
    emit(state.copyWith(expandedGroupIds: currentExpanded));
  }

  void selectFilter(int index) {
    emit(state.copyWith(selectedFilterIndex: index));
  }

  void updateSearch(String query) {
    emit(state.copyWith(searchQuery: query));
  }
}
