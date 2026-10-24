import 'package:bloc/bloc.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/groups/domain/repository/group_repository.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_edit_state.dart';

class MeetingEditCubit extends Cubit<MeetingEditState> {
  MeetingEditCubit({required this.groupRepository})
    : super(const MeetingEditIdle());

  final GroupRepository groupRepository;

  Future<void> submit({
    required String meetingId,
    required DateTime date,
    String? googlePlaceId,
    String? description,
  }) async {
    if (state is MeetingEditSubmitting) return;
    emit(const MeetingEditSubmitting());

    final result = await groupRepository.updateMeeting(
      meetingId: meetingId,
      date: date,
      googlePlaceId: googlePlaceId,
      description: description,
    );
    if (isClosed) return;

    switch (result) {
      case Failure(:final failure):
        emit(MeetingEditError(failure.message));
      case Success():
        emit(const MeetingEditSuccess());
    }
  }
}
