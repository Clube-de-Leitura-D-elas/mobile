import 'package:mobile/features/notifications/domain/entities/notification_entity.dart';
import 'package:mobile/features/notifications/domain/entities/notification_type.dart';

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime date;
  final bool isRead;
  final String? meetingId;
  final String? groupId;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.date,
    required this.isRead,
    this.meetingId,
    this.groupId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: _parseType(json['type']),
      date: DateTime.parse(json['date'] as String),
      isRead: json['is_read'] as bool,
      meetingId: json['meeting_id'] as String?,
      groupId: json['group_id'] as String?,
    );
  }

  static NotificationType _parseType(dynamic value) {
    return switch (value) {
      'BIRTHDAY' => NotificationType.birthday,
      'BOOK_SUGGESTIONS_REMINDER' => NotificationType.bookSuggestionsReminder,
      'COORDINATOR_TASKS_REMINDER' => NotificationType.coordinatorTasksReminder,
      'HOST_TASKS_REMINDER' => NotificationType.hostTasksReminder,
      'MEETING_REMINDER' => NotificationType.meetingReminder,
      'MEETING_SCHEDULE_PENDING' => NotificationType.meetingSchedulePending,
      'MEETING_UPDATED' => NotificationType.meetingUpdated,
      'DRAW_RESULT' => NotificationType.drawResult,
      'GROUP_JOIN_REQUESTED' => NotificationType.groupJoinRequested,
      'GROUP_JOIN_APPROVED' => NotificationType.groupJoinApproved,
      'GROUP_JOIN_REJECTED' => NotificationType.groupJoinRejected,
      'MEETING_GUEST_APPROVED' => NotificationType.meetingGuestApproved,
      'MEETING_GUEST_REJECTED' => NotificationType.meetingGuestRejected,
      _ => NotificationType.unknown,
    };
  }

  NotificationEntity toDomain() {
    return NotificationEntity(
      id: id,
      title: title,
      message: message,
      type: type,
      date: date,
      isRead: isRead,
      meetingId: meetingId,
      groupId: groupId,
    );
  }
}
