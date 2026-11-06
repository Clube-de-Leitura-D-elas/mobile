import 'package:equatable/equatable.dart';
import 'package:mobile/features/notifications/domain/entities/notification_type.dart';

class NotificationEntity extends Equatable {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime date;
  final bool isRead;
  final String? meetingId;
  final String? groupId;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.date,
    required this.isRead,
    this.meetingId,
    this.groupId,
  });

  NotificationEntity copyWith({required bool isRead}) {
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

  @override
  List<Object?> get props => [
    id,
    title,
    message,
    type,
    date,
    isRead,
    meetingId,
    groupId,
  ];
}
