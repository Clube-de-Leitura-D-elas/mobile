import 'package:equatable/equatable.dart';
import 'package:mobile/features/groups/domain/entities/meeting_invitation_status.dart';

enum PresenceStatus { present, absent }

class MeetingAttendee extends Equatable {
  const MeetingAttendee({
    required this.id,
    required this.name,
    required this.invitation,
    this.photoUrl,
    this.presence,
  });

  final String id;
  final String name;
  final String? photoUrl;
  final MeetingInvitationStatus invitation;

  /// null = registro ainda não feito.
  final PresenceStatus? presence;

  MeetingAttendee copyWith({PresenceStatus? presence}) => MeetingAttendee(
    id: id,
    name: name,
    photoUrl: photoUrl,
    invitation: invitation,
    presence: presence ?? this.presence,
  );

  @override
  List<Object?> get props => [id, name, photoUrl, invitation, presence];
}
