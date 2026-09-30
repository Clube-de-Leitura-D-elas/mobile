import 'package:equatable/equatable.dart';
import 'package:mobile/features/groups/domain/entities/group_meeting.dart';

class GroupEntity extends Equatable {
  final String id;
  final String name;
  final int participantsCount;
  final String cityState;
  final String? photoUrl;
  final GroupMeeting? nextMeeting;
  final bool hasPendingResponse;

  const GroupEntity({
    required this.id,
    required this.name,
    required this.participantsCount,
    required this.cityState,
    this.photoUrl,
    this.nextMeeting,
    this.hasPendingResponse = false,
  });

  GroupEntity copyWith({
    String? id,
    String? name,
    int? participantsCount,
    String? cityState,
    String? photoUrl,
    GroupMeeting? nextMeeting,
    bool? hasPendingResponse,
  }) {
    return GroupEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      participantsCount: participantsCount ?? this.participantsCount,
      cityState: cityState ?? this.cityState,
      photoUrl: photoUrl ?? this.photoUrl,
      nextMeeting: nextMeeting ?? this.nextMeeting,
      hasPendingResponse: hasPendingResponse ?? this.hasPendingResponse,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        participantsCount,
        cityState,
        photoUrl,
        nextMeeting,
        hasPendingResponse,
      ];
}
