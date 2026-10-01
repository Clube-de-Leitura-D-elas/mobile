import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/groups/domain/repository/group_repository.dart';
import 'package:mobile/features/groups/domain/entities/group_meeting.dart';
import 'package:mobile/core/tools/result.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final GroupRepository groupRepository;

  HomeCubit({required this.groupRepository}) : super(const HomeState());

  Future<void> loadGroups() async {
    emit(state.copyWith(status: HomeStatus.loading));

    final result = await groupRepository.getMyGroups();
    if (isClosed) return;

    switch (result) {
      case Failure(:final failure):
        emit(
          state.copyWith(
            status: HomeStatus.error,
            errorMessage: failure.message,
          ),
        );
      case Success(:final data):
        final expandedGroupIds = data
            .where((group) => group.nextMeeting != null)
            .map((group) => group.id)
            .toSet();
        emit(
          state.copyWith(
            status: HomeStatus.loaded,
            groups: data,
            expandedGroupIds: expandedGroupIds,
          ),
        );
    }
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

  Future<void> setMeetingPresence(
    String meetingId,
    MeetingPresenceResponse response,
  ) async {
    final result = await groupRepository.setMeetingPresence(
      meetingId,
      response,
    );
    if (isClosed) return;

    switch (result) {
      case Failure(:final failure):
        emit(
          state.copyWith(
            status: HomeStatus.error,
            errorMessage: failure.message,
          ),
        );
      case Success():
        await loadGroups();
    }
  }
}
