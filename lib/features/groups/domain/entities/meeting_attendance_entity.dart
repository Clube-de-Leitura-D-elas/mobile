import 'package:equatable/equatable.dart';
import 'package:mobile/features/groups/domain/entities/meeting_invitation_status.dart';
import 'package:mobile/features/groups/domain/entities/meeting_presence_status.dart';

class MeetingAttendanceEntity extends Equatable {
  final String id;
  final String name;
  final String? photoUrl;
  final MeetingInvitationStatus invitationStatus;
  final MeetingPresenceStatus? presenceStatus;

  const MeetingAttendanceEntity({
    required this.id,
    required this.name,
    this.photoUrl,
    required this.invitationStatus,
    required this.presenceStatus,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    photoUrl,
    invitationStatus,
    presenceStatus,
  ];
}
