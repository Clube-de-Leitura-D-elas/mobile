import 'package:equatable/equatable.dart';
import 'package:mobile/features/groups/domain/entities/group_meeting_status.dart';
import 'package:mobile/features/groups/domain/entities/meeting_invitation_status.dart';

class GroupMeeting extends Equatable {
  final String? id;
  final String hostName;
  final String bookTitle;
  final String date;
  final String location;
  final String? bookCoverUrl;
  final MeetingInvitationStatus invitationStatus;
  final bool canManageTasks;
  final int tasksDone;
  final int tasksTotal;
  final GroupMeetingStatus status;

  const GroupMeeting({
    this.id,
    required this.hostName,
    required this.bookTitle,
    required this.date,
    required this.location,
    this.bookCoverUrl,
    this.invitationStatus = MeetingInvitationStatus.pending,
    this.canManageTasks = false,
    this.tasksDone = 0,
    this.tasksTotal = 2,
    this.status = GroupMeetingStatus.scheduled,
  });

  bool get isEnded => status == GroupMeetingStatus.ended;

  /// Encontro encerrado da anfitriã: as tarefas ficam só na tela de pendências.
  bool get hidesNextEventForHost => isEnded && canManageTasks;

  @override
  List<Object?> get props => [
    id,
    hostName,
    bookTitle,
    date,
    location,
    bookCoverUrl,
    invitationStatus,
    canManageTasks,
    tasksDone,
    tasksTotal,
    status,
  ];
}
