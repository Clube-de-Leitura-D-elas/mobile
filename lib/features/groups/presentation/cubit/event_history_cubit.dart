import 'package:bloc/bloc.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/groups/domain/repository/group_repository.dart';
import 'package:mobile/features/groups/presentation/cubit/event_history_state.dart';

class EventHistoryCubit extends Cubit<EventHistoryState> {
  EventHistoryCubit({required this.groupRepository})
    : super(const EventHistoryLoading());

  final GroupRepository groupRepository;

  Future<void> load(String groupId) async {
    emit(const EventHistoryLoading());

    final result = await groupRepository.getEventHistory(groupId);
    if (isClosed) return;

    switch (result) {
      case Failure(:final failure):
        emit(EventHistoryError(failure.message));
      case Success(:final data):
        if (data.isEmpty) {
          emit(const EventHistoryEmpty());
          return;
        }
        emit(EventHistoryLoaded(data));
    }
  }
}
