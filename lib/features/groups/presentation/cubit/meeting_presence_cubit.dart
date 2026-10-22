import 'package:bloc/bloc.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/groups/domain/entities/meeting_attendance_entity.dart';
import 'package:mobile/features/groups/domain/entities/meeting_presence_status.dart';
import 'package:mobile/features/groups/domain/repository/group_repository.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_presence_state.dart';

class MeetingPresenceCubit extends Cubit<MeetingPresenceState> {
  MeetingPresenceCubit({required GroupRepository repository})
    : _repository = repository,
      super(const MeetingPresenceLoading());

  final GroupRepository _repository;
  String _meetingId = '';

  Future<void> load(String meetingId) async {
    _meetingId = meetingId;
    emit(const MeetingPresenceLoading());

    final result = await _repository.getMeetingAttendance(meetingId);

    result.match((attendees) {
      final alreadyRegistered = attendees.any((a) => a.presenceStatus != null);
      emit(
        alreadyRegistered
            ? MeetingPresenceClosed(attendees)
            : MeetingPresenceEditing(attendees: attendees),
      );
    }, (failure) => emit(MeetingPresenceError(failure.message)));
  }

  void toggle(String attendeeId) {
    final current = state;
    if (current is! MeetingPresenceEditing || current.isSubmitting) return;

    final marked = {...current.marked};
    marked.contains(attendeeId)
        ? marked.remove(attendeeId)
        : marked.add(attendeeId);
    emit(current.copyWith(marked: marked, clearSubmitError: true));
  }

  Future<void> confirm() async {
    final current = state;
    if (current is! MeetingPresenceEditing || current.isSubmitting) return;

    emit(current.copyWith(isSubmitting: true, clearSubmitError: true));

    final result = await _repository.setMeetingPresence(
      _meetingId,
      current.marked.toList(),
    );

    result.match(
      (_) => emit(
        MeetingPresenceClosed([
          for (final a in current.attendees)
            MeetingAttendanceEntity(
              id: a.id,
              name: a.name,
              photoUrl: a.photoUrl,
              invitationStatus: a.invitationStatus,
              presenceStatus: current.marked.contains(a.id)
                  ? MeetingPresenceStatus.present
                  : MeetingPresenceStatus.absent,
            ),
        ]),
      ),
      // Mantém as marcações para nova tentativa.
      (failure) => emit(
        current.copyWith(isSubmitting: false, submitError: failure.message),
      ),
    );
  }
}
