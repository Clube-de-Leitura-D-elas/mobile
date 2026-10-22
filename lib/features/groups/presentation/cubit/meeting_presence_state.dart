import 'package:equatable/equatable.dart';
import 'package:mobile/features/groups/domain/entities/meeting_attendance_entity.dart';

sealed class MeetingPresenceState extends Equatable {
  const MeetingPresenceState();

  @override
  List<Object?> get props => [];
}

class MeetingPresenceLoading extends MeetingPresenceState {
  const MeetingPresenceLoading();
}

class MeetingPresenceError extends MeetingPresenceState {
  const MeetingPresenceError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

class MeetingPresenceEditing extends MeetingPresenceState {
  const MeetingPresenceEditing({
    required this.attendees,
    this.marked = const {},
    this.isSubmitting = false,
    this.submitError,
  });

  final List<MeetingAttendanceEntity> attendees;
  final Set<String> marked;
  final bool isSubmitting;
  final String? submitError;

  MeetingPresenceEditing copyWith({
    Set<String>? marked,
    bool? isSubmitting,
    String? submitError,
    bool clearSubmitError = false,
  }) => MeetingPresenceEditing(
    attendees: attendees,
    marked: marked ?? this.marked,
    isSubmitting: isSubmitting ?? this.isSubmitting,
    submitError: clearSubmitError ? null : (submitError ?? this.submitError),
  );

  @override
  List<Object?> get props => [attendees, marked, isSubmitting, submitError];
}

class MeetingPresenceClosed extends MeetingPresenceState {
  const MeetingPresenceClosed(this.attendees);
  final List<MeetingAttendanceEntity> attendees;

  @override
  List<Object?> get props => [attendees];
}
