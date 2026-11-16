import 'package:equatable/equatable.dart';
import 'package:mobile/features/groups/domain/entities/group_entity.dart';

class GroupDetailsEntity extends Equatable {
  final String name;
  final List<String> genres;
  final int participantCount;
  final String city;
  final String stateCode;
  final String? coverImageUrl;
  final String? whatsappUrl;
  final PendingRaffle? pendingRaffle;
  final bool hasOpenMeeting;
  final String? openMeetingStatus;

  const GroupDetailsEntity({
    required this.name,
    required this.genres,
    required this.participantCount,
    required this.city,
    required this.stateCode,
    this.coverImageUrl,
    this.whatsappUrl,
    this.pendingRaffle,
    this.hasOpenMeeting = false,
    this.openMeetingStatus,
  });

  @override
  List<Object?> get props => [
    name,
    genres,
    participantCount,
    city,
    stateCode,
    coverImageUrl,
    whatsappUrl,
    pendingRaffle,
    hasOpenMeeting,
    openMeetingStatus,
  ];
}
