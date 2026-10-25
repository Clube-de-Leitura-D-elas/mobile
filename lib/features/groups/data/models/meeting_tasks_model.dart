import 'package:mobile/features/groups/domain/entities/meeting_tasks_entity.dart';

class MeetingTasksModel extends MeetingTasksEntity {
  const MeetingTasksModel({
    required super.meetingId,
    required super.status,
    required super.canManageTasks,
    required super.canConclude,
    required super.schedule,
    required super.record,
  });

  factory MeetingTasksModel.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) {
      throw const FormatException('Invalid meeting tasks response.');
    }
    final meetingId = json['meeting_id'];
    final status = _status(json['status']);
    final canManageTasks = json['can_manage_tasks'];
    final canConclude = json['can_conclude'];
    final tasks = json['tasks'];
    if (meetingId is! String || canManageTasks is! bool) {
      throw const FormatException('Invalid meeting tasks response.');
    }

    final scheduleJson = tasks is Map<String, dynamic>
        ? tasks['schedule']
        : null;
    final recordJson = tasks is Map<String, dynamic> ? tasks['record'] : null;
    final schedule = _parseSchedule(scheduleJson, status);
    final record = _parseRecord(recordJson);

    return MeetingTasksModel(
      meetingId: meetingId,
      status: status,
      canManageTasks: canManageTasks,
      canConclude: canConclude is bool ? canConclude : false,
      schedule: schedule,
      record: record,
    );
  }

  static MeetingScheduleTask _parseSchedule(
    dynamic json,
    MeetingTaskStatus status,
  ) {
    if (json == null) {
      return MeetingScheduleTask(done: status != MeetingTaskStatus.created);
    }
    if (json is! Map<String, dynamic> || json['done'] is! bool) {
      throw const FormatException('Invalid meeting tasks response.');
    }
    final date = json['date'];
    final parsedDate = date is String ? DateTime.tryParse(date) : null;
    if (date != null && (date is! String || parsedDate == null)) {
      throw const FormatException('Invalid meeting tasks response.');
    }
    final location = json['location'];
    if (location != null && location is! String) {
      throw const FormatException('Invalid meeting tasks response.');
    }
    return MeetingScheduleTask(
      done: json['done'] as bool,
      date: parsedDate,
      location: location as String?,
    );
  }

  static MeetingRecordTask _parseRecord(dynamic json) {
    if (json == null) {
      return const MeetingRecordTask(MeetingRecordStatus.locked);
    }
    if (json is! Map<String, dynamic>) {
      throw const FormatException('Invalid meeting tasks response.');
    }
    return MeetingRecordTask(_recordStatus(json['status']));
  }

  static MeetingTaskStatus _status(dynamic value) => switch (value) {
    'SCHEDULED' => MeetingTaskStatus.scheduled,
    'IN_PROGRESS' => MeetingTaskStatus.inProgress,
    'CONCLUDED' => MeetingTaskStatus.concluded,
    _ => MeetingTaskStatus.created,
  };

  static MeetingRecordStatus _recordStatus(dynamic value) => switch (value) {
    'PENDING' => MeetingRecordStatus.pending,
    'DRAFT' => MeetingRecordStatus.draft,
    'PUBLISHED' => MeetingRecordStatus.published,
    _ => MeetingRecordStatus.locked,
  };

  MeetingTasksEntity toDomain() => this;
}
