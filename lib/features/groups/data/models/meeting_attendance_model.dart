import 'package:mobile/features/groups/domain/entities/meeting_attendance_entity.dart';
import 'package:mobile/features/groups/domain/entities/meeting_invitation_status.dart';
import 'package:mobile/features/groups/domain/entities/meeting_presence_status.dart';

class MeetingAttendanceModel {
  final String id;
  final String name;
  final String? photoUrl;
  final String invitationStatus;
  final String? presenceStatus;

  const MeetingAttendanceModel({
    required this.id,
    required this.name,
    this.photoUrl,
    required this.invitationStatus,
    this.presenceStatus,
  });

  factory MeetingAttendanceModel.fromJson(Map<String, dynamic> json) {
    return MeetingAttendanceModel(
      id: json['id'] as String? ?? json['user_id'] as String? ?? '',
      name: json['name'] as String? ?? json['nome'] as String? ?? '',
      photoUrl: json['photo_url'] as String? ?? json['foto'] as String?,
      invitationStatus: json['invitation_status'] as String? ?? 'PENDING',
      presenceStatus: json['presence_status'] as String?,
    );
  }

  static List<MeetingAttendanceModel> listFromJson(dynamic json) {
    final dynamic data = json is Map<String, dynamic> ? json['data'] : json;

    if (data is! List) {
      return [];
    }

    return data
        .map(
          (e) => MeetingAttendanceModel.fromJson(
            Map<String, dynamic>.from(e as Map),
          ),
        )
        .toList();
  }

  MeetingAttendanceEntity toDomain() {
    return MeetingAttendanceEntity(
      id: id,
      name: name,
      photoUrl: photoUrl,
      invitationStatus: switch (invitationStatus.toUpperCase()) {
        'CONFIRMED' => MeetingInvitationStatus.confirmed,
        'DECLINED' => MeetingInvitationStatus.declined,
        _ => MeetingInvitationStatus.pending,
      },
      presenceStatus: switch (presenceStatus?.toUpperCase()) {
        'PRESENT' => MeetingPresenceStatus.present,
        'ABSENT' => MeetingPresenceStatus.absent,
        _ => null,
      },
    );
  }
}
