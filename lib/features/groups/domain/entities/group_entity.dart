import 'package:equatable/equatable.dart';
import 'package:mobile/features/groups/domain/entities/group_meeting.dart';

class GroupEntity extends Equatable {
  final String id;
  final int number;
  final int participantsCount;
  final String cityState;
  final String? photoUrl;
  final GroupMeeting? nextMeeting;
  final List<GroupMeeting> pendingMeetings;
  final bool hasPendingResponse;

  const GroupEntity({
    required this.id,
    required this.number,
    required this.participantsCount,
    required this.cityState,
    this.photoUrl,
    this.nextMeeting,
    this.pendingMeetings = const [],
    this.hasPendingResponse = false,
  });

  GroupEntity copyWith({
    String? id,
    int? number,
    int? participantsCount,
    String? cityState,
    String? photoUrl,
    GroupMeeting? nextMeeting,
    List<GroupMeeting>? pendingMeetings,
    bool? hasPendingResponse,
  }) {
    return GroupEntity(
      id: id ?? this.id,
      number: number ?? this.number,
      participantsCount: participantsCount ?? this.participantsCount,
      cityState: cityState ?? this.cityState,
      photoUrl: photoUrl ?? this.photoUrl,
      nextMeeting: nextMeeting ?? this.nextMeeting,
      pendingMeetings: pendingMeetings ?? this.pendingMeetings,
      hasPendingResponse: hasPendingResponse ?? this.hasPendingResponse,
    );
  }

  bool get hasAnsweredNextMeeting => nextMeeting != null && !hasPendingResponse;

  @override
  List<Object?> get props => [
    id,
    number,
    participantsCount,
    cityState,
    photoUrl,
    nextMeeting,
    pendingMeetings,
    hasPendingResponse,
  ];
}
