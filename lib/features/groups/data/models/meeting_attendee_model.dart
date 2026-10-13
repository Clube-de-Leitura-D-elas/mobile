import 'package:mobile/features/groups/domain/entities/meeting_atendee.dart';
import 'package:mobile/features/groups/domain/entities/meeting_invitation_status.dart';

class MeetingAttendeeModel extends MeetingAttendee {
  const MeetingAttendeeModel({
    required super.id,
    required super.name,
    required super.invitation,
    super.photoUrl,
    super.presence,
  });

  factory MeetingAttendeeModel.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) {
      throw const FormatException('Invalid meeting attendee response.');
    }

    final id = json['id'];
    final name = json['name'];
    final photoUrl = json['photo_url'];
    if (id is! String || name is! String) {
      throw const FormatException('Invalid meeting attendee response.');
    }

    return MeetingAttendeeModel(
      id: id,
      name: name,
      photoUrl: photoUrl is String ? photoUrl : null,
      invitation: _parseInvitation(json['invitation_status']),
      presence: _parsePresence(json['presence_status']),
    );
  }

  static List<MeetingAttendeeModel> listFromEnvelope(dynamic json) {
    if (json is! Map<String, dynamic> || json['attendees'] is! List) {
      throw const FormatException('Invalid meeting attendance response.');
    }

    return (json['attendees'] as List)
        .map(MeetingAttendeeModel.fromJson)
        .toList(growable: false);
  }

  static MeetingInvitationStatus _parseInvitation(dynamic value) {
    return switch (value) {
      'CONFIRMED' => MeetingInvitationStatus.confirmed,
      'DECLINED' => MeetingInvitationStatus.declined,
      _ => MeetingInvitationStatus.pending,
    };
  }

  static PresenceStatus? _parsePresence(dynamic value) {
    return switch (value) {
      'PRESENT' => PresenceStatus.present,
      'ABSENT' => PresenceStatus.absent,
      _ => null,
    };
  }

  MeetingAttendee toDomain() => MeetingAttendee(
    id: id,
    name: name,
    photoUrl: photoUrl,
    invitation: invitation,
    presence: presence,
  );
}
