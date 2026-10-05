import 'package:bloc/bloc.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/groups/domain/entities/meeting_invitation_status.dart';
import 'package:mobile/features/groups/domain/repository/group_repository.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_invitation_state.dart';

class MeetingInvitationCubit extends Cubit<MeetingInvitationState> {
  MeetingInvitationCubit({
    required this.groupRepository,
    required String meetingId,
    MeetingInvitationStatus initialStatus = MeetingInvitationStatus.pending,
  }) : _meetingId = meetingId,
       super(MeetingInvitationIdle(initialStatus));

  final GroupRepository groupRepository;
  final String _meetingId;

  Future<void> respond(MeetingInvitationStatus status) async {
    if (state is MeetingInvitationSubmitting) return;

    final previous = state.currentStatus;
    emit(MeetingInvitationSubmitting(previous, status));

    final result = await groupRepository.setMeetingInvitationResponse(
      _meetingId,
      status,
    );
    if (isClosed) return;

    switch (result) {
      case Failure(:final failure):
        emit(MeetingInvitationError(previous, failure.message, status));
      case Success():
        emit(MeetingInvitationIdle(status));
    }
  }
}
