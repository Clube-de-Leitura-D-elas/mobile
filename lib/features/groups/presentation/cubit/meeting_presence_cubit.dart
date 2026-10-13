import 'package:bloc/bloc.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/groups/domain/entities/meeting_atendee.dart';
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
      final sorted = [...attendees]
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      final alreadyRegistered = sorted.any((a) => a.presence != null);
      emit(
        alreadyRegistered
            ? MeetingPresenceClosed(sorted)
            : MeetingPresenceEditing(attendees: sorted),
      );
    }, (failure) => emit(MeetingPresenceError(failure.message)));
  }

  void toggle(String userId) {
    final current = state;
    if (current is! MeetingPresenceEditing || current.isSubmitting) return;

    final marked = {...current.marked};
    marked.contains(userId) ? marked.remove(userId) : marked.add(userId);
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
            a.copyWith(
              presence: current.marked.contains(a.id)
                  ? PresenceStatus.present
                  : PresenceStatus.absent,
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
