import 'package:mobile/features/groups/domain/entities/group_details_entity.dart';
import 'package:mobile/features/groups/domain/entities/group_entity.dart';

class GroupDetailsModel extends GroupDetailsEntity {
  const GroupDetailsModel({
    required super.name,
    required super.genres,
    required super.participantCount,
    required super.city,
    required super.stateCode,
    super.coverImageUrl,
    super.whatsappUrl,
    super.pendingRaffle,
    super.hasOpenMeeting,
    super.openMeetingStatus,
  });

  factory GroupDetailsModel.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) {
      throw const FormatException('Invalid group details response.');
    }

    final name = json['name'];
    final genres = json['genres'];
    final participantCount = json['participant_count'];
    final city = json['city'];
    final stateCode = json['state_code'];
    final coverImageUrl = json['cover_image_url'];
    final whatsappUrl = json['whatsapp_url'];
    final pendingRaffle = _parsePendingRaffle(json['pending_raffle']);
    final hasOpenMeeting = json['has_open_meeting'] as bool? ?? false;
    final openMeetingStatus = json['open_meeting_status'] as String?;

    if (name is! String ||
        genres is! List ||
        genres.any((genre) => genre is! String) ||
        participantCount is! int ||
        (city != null && city is! String) ||
        (stateCode != null && stateCode is! String) ||
        (coverImageUrl != null && coverImageUrl is! String) ||
        (whatsappUrl != null && whatsappUrl is! String)) {
      throw const FormatException('Invalid group details response.');
    }

    return GroupDetailsModel(
      name: name,
      genres: List<String>.from(genres),
      participantCount: participantCount,
      city: city as String? ?? '',
      stateCode: stateCode as String? ?? '',
      coverImageUrl: coverImageUrl as String?,
      whatsappUrl: whatsappUrl as String?,
      pendingRaffle: pendingRaffle,
      hasOpenMeeting: hasOpenMeeting,
      openMeetingStatus: openMeetingStatus,
    );
  }

  static PendingRaffle? _parsePendingRaffle(dynamic json) {
    if (json == null || json is! Map<String, dynamic>) return null;
    final typeStr = json['type'] as String?;
    final groupId = json['group_id'] as String?;
    final meetingId = json['meeting_id'] as String?;
    if (groupId == null) return null;
    final type = typeStr == 'INAUGURAL'
        ? PendingRaffleType.inaugural
        : PendingRaffleType.pending;
    return PendingRaffle(type: type, groupId: groupId, meetingId: meetingId);
  }

  GroupDetailsEntity toDomain() {
    return GroupDetailsEntity(
      name: name,
      genres: genres,
      participantCount: participantCount,
      city: city,
      stateCode: stateCode,
      coverImageUrl: coverImageUrl,
      whatsappUrl: whatsappUrl,
      pendingRaffle: pendingRaffle,
      hasOpenMeeting: hasOpenMeeting,
      openMeetingStatus: openMeetingStatus,
    );
  }
}
