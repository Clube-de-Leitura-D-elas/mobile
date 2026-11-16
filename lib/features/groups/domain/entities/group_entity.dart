import 'package:equatable/equatable.dart';
import 'package:mobile/features/groups/domain/entities/group_meeting.dart';

enum PendingRaffleType { inaugural, pending }

class PendingRaffle extends Equatable {
  final PendingRaffleType type;
  final String groupId;
  final String? meetingId;

  const PendingRaffle({
    required this.type,
    required this.groupId,
    this.meetingId,
  });

  @override
  List<Object?> get props => [type, groupId, meetingId];
}

class GroupEntity extends Equatable {
  final String id;
  final int number;
  final int participantsCount;
  final String cityState;
  final String? photoUrl;
  final GroupMeeting? nextMeeting;

  /// Encontros do grupo em que a usuária ainda tem tarefas a concluir.
  final List<GroupMeeting> pendingMeetings;
  final bool hasPendingResponse;

  /// Sorteio disponível quando o grupo não tem encontro aberto.
  final PendingRaffle? pendingRaffle;
  final bool hasOpenMeeting;
  final String? openMeetingStatus;

  const GroupEntity({
    required this.id,
    required this.number,
    required this.participantsCount,
    required this.cityState,
    this.photoUrl,
    this.nextMeeting,
    this.pendingMeetings = const [],
    this.hasPendingResponse = false,
    this.pendingRaffle,
    this.hasOpenMeeting = false,
    this.openMeetingStatus,
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
    PendingRaffle? pendingRaffle,
    bool? hasOpenMeeting,
    String? openMeetingStatus,
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
      pendingRaffle: pendingRaffle ?? this.pendingRaffle,
      hasOpenMeeting: hasOpenMeeting ?? this.hasOpenMeeting,
      openMeetingStatus: openMeetingStatus ?? this.openMeetingStatus,
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
    pendingRaffle,
    hasOpenMeeting,
    openMeetingStatus,
  ];
}
