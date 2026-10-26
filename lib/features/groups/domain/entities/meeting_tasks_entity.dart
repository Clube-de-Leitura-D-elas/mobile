import 'package:equatable/equatable.dart';

enum MeetingTaskStatus { created, scheduled, inProgress, concluded }

enum MeetingRecordStatus { locked, pending, draft, published }

class MeetingScheduleTask extends Equatable {
  const MeetingScheduleTask({required this.done, this.date, this.location});

  final bool done;
  final DateTime? date;
  final String? location;

  @override
  List<Object?> get props => [done, date, location];
}

class MeetingRecordTask extends Equatable {
  const MeetingRecordTask(this.status);

  final MeetingRecordStatus status;

  bool get done => status == MeetingRecordStatus.published;

  bool get available =>
      status == MeetingRecordStatus.pending ||
      status == MeetingRecordStatus.draft;

  @override
  List<Object?> get props => [status];
}

class MeetingTasksEntity extends Equatable {
  const MeetingTasksEntity({
    required this.meetingId,
    required this.status,
    required this.canManageTasks,
    required this.canConclude,
    required this.schedule,
    required this.record,
    this.bookTitle,
    this.bookAuthor,
    this.groupName,
  });

  static const totalTasks = 2;

  final String meetingId;
  final MeetingTaskStatus status;
  final bool canManageTasks;
  final bool canConclude;
  final MeetingScheduleTask schedule;
  final MeetingRecordTask record;

  /// Dados do banner "Você foi sorteada". Opcionais: o contrato de
  /// `get-meeting-tasks` ainda não garante esses campos.
  final String? bookTitle;
  final String? bookAuthor;
  final String? groupName;

  bool get isPublished => status != MeetingTaskStatus.created;

  bool get isConcluded => status == MeetingTaskStatus.concluded;

  int get completedTasks => (schedule.done ? 1 : 0) + (record.done ? 1 : 0);

  int get pendingTasks => totalTasks - completedTasks;

  @override
  List<Object?> get props => [
    meetingId,
    status,
    canManageTasks,
    canConclude,
    schedule,
    record,
    bookTitle,
    bookAuthor,
    groupName,
  ];
}
