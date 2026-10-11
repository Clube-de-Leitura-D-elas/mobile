import 'package:mobile/features/groups/domain/entities/group_entity.dart';
import 'package:mobile/features/groups/domain/entities/group_meeting.dart';
import 'package:mobile/features/groups/domain/entities/meeting_invitation_status.dart';

class GroupModel extends GroupEntity {
  const GroupModel({
    required super.id,
    required super.number,
    required super.participantsCount,
    required super.cityState,
    super.photoUrl,
    super.nextMeeting,
    super.hasPendingResponse,
  });

  factory GroupModel.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) {
      throw const FormatException('Invalid group.');
    }

    final id = json['id'];
    final number = _parseNumber(json['number'], json['name']);
    final participantsCount = json['participant_count'];
    final cityState = json['city_state'];
    final photoUrl = json['photo_url'];
    final nextMeeting = _parseNextMeeting(json['next_meeting']);
    final hasPendingResponse = json['has_pending_response'];

    if (id is! String ||
        number == null ||
        participantsCount is! int ||
        cityState is! String ||
        (photoUrl != null && photoUrl is! String) ||
        (hasPendingResponse != null && hasPendingResponse is! bool)) {
      throw const FormatException('Invalid group.');
    }

    return GroupModel(
      id: id,
      number: number,
      participantsCount: participantsCount,
      cityState: cityState,
      photoUrl: photoUrl as String?,
      nextMeeting: nextMeeting,
      hasPendingResponse: hasPendingResponse as bool? ?? false,
    );
  }

  static int? _parseNumber(dynamic number, dynamic name) {
    if (number is int) return number;
    if (name is! String) return null;

    return int.tryParse(name) ??
        int.tryParse(RegExp(r'\d+$').firstMatch(name)?.group(0) ?? '');
  }

  static GroupMeeting? _parseNextMeeting(dynamic json) {
    if (json == null) return null;
    if (json is! Map<String, dynamic>) {
      throw const FormatException('Invalid next meeting.');
    }

    final id = json['id'];
    final hostName = json['host_name'];
    final bookTitle = json['book_title'];
    final date = json['date'];
    final location = json['location'];
    final invitationStatus = json['invitation_status'];

    if (id is! String ||
        hostName is! String ||
        bookTitle is! String ||
        date is! String ||
        location is! String) {
      throw const FormatException('Invalid next meeting.');
    }

    return GroupMeeting(
      id: id,
      hostName: hostName,
      bookTitle: bookTitle,
      date: date,
      location: location,
      invitationStatus: _parseInvitationStatus(invitationStatus),
    );
  }

  static List<GroupModel> listFromJson(dynamic json) {
    if (json is! Map<String, dynamic> || json['groups'] is! List) {
      throw const FormatException('Invalid groups response.');
    }

    return (json['groups'] as List).map(GroupModel.fromJson).toList();
  }

  GroupEntity toDomain() {
    return GroupEntity(
      id: id,
      number: number,
      participantsCount: participantsCount,
      cityState: cityState,
      photoUrl: photoUrl,
      nextMeeting: nextMeeting,
      hasPendingResponse: hasPendingResponse,
    );
  }

  static MeetingInvitationStatus _parseInvitationStatus(dynamic value) {
    return switch (value) {
      'CONFIRMED' => MeetingInvitationStatus.confirmed,
      'DECLINED' => MeetingInvitationStatus.declined,
      _ => MeetingInvitationStatus.pending,
    };
  }
}
