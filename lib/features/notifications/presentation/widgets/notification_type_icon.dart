import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/notifications/domain/entities/notification_type.dart';

AppIconAsset notificationIconFor(NotificationType type) => switch (type) {
  NotificationType.birthday => AppIcons.user,
  NotificationType.bookSuggestionsReminder => AppIcons.book,
  NotificationType.coordinatorTasksReminder => AppIcons.tasks,
  NotificationType.hostTasksReminder => AppIcons.tasks,
  NotificationType.meetingReminder => AppIcons.clock,
  NotificationType.meetingSchedulePending => AppIcons.calendar,
  NotificationType.meetingUpdated => AppIcons.calendar,
  NotificationType.drawResult => AppIcons.book,
  NotificationType.unknown => AppIcons.bell,
};
