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
  });

  final String meetingId;
  final MeetingTaskStatus status;
  final bool canManageTasks;
  final bool canConclude;
  final MeetingScheduleTask schedule;
  final MeetingRecordTask record;

  int get completedTasks =>
      (schedule.done ? 1 : 0) +
      (record.status == MeetingRecordStatus.published ? 1 : 0);

  @override
  List<Object?> get props => [
    meetingId,
    status,
    canManageTasks,
    canConclude,
    schedule,
    record,
  ];
}
