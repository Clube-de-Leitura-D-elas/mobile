import 'package:bloc/bloc.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/groups/domain/repository/group_repository.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_details_state.dart';

class MeetingDetailsCubit extends Cubit<MeetingDetailsState> {
  MeetingDetailsCubit({required this.groupRepository})
    : super(const MeetingDetailsLoading());

  final GroupRepository groupRepository;

  Future<void> load(String meetingId) async {
    emit(const MeetingDetailsLoading());

    final result = await groupRepository.getMeetingDetails(meetingId);
    if (isClosed) return;

    switch (result) {
      case Failure(:final failure):
        emit(MeetingDetailsError(failure.message));
      case Success(:final data):
        emit(MeetingDetailsLoaded(data));
    }
  }
}
