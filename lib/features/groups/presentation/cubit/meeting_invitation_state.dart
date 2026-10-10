import 'package:equatable/equatable.dart';
import 'package:mobile/features/groups/domain/entities/meeting_invitation_status.dart';

sealed class MeetingInvitationState extends Equatable {
  const MeetingInvitationState();

  MeetingInvitationStatus get currentStatus;

  @override
  List<Object?> get props => [currentStatus];
}

class MeetingInvitationIdle extends MeetingInvitationState {
  const MeetingInvitationIdle(this.currentStatus);

  @override
  final MeetingInvitationStatus currentStatus;
}

class MeetingInvitationSubmitting extends MeetingInvitationState {
  const MeetingInvitationSubmitting(this.currentStatus, this.pendingStatus);

  @override
  final MeetingInvitationStatus currentStatus;

  final MeetingInvitationStatus pendingStatus;

  @override
  List<Object?> get props => [currentStatus, pendingStatus];
}

class MeetingInvitationError extends MeetingInvitationState {
  const MeetingInvitationError(
    this.currentStatus,
    this.message,
    this.attemptedStatus,
  );

  @override
  final MeetingInvitationStatus currentStatus;

  final String message;
  final MeetingInvitationStatus attemptedStatus;

  @override
  List<Object?> get props => [currentStatus, message, attemptedStatus];
}
