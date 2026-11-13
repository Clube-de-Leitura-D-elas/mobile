import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/notifications/domain/entities/notification_type.dart';
import 'package:mobile/features/notifications/presentation/widgets/notification_type_icon.dart';

void main() {
  const expectedIcons = {
    NotificationType.birthday: AppIcons.user,
    NotificationType.bookSuggestionsReminder: AppIcons.book,
    NotificationType.coordinatorTasksReminder: AppIcons.tasks,
    NotificationType.hostTasksReminder: AppIcons.tasks,
    NotificationType.meetingReminder: AppIcons.clock,
    NotificationType.meetingSchedulePending: AppIcons.calendar,
    NotificationType.meetingUpdated: AppIcons.calendar,
    NotificationType.drawResult: AppIcons.book,
    NotificationType.groupJoinRequested: AppIcons.group,
    NotificationType.groupJoinApproved: AppIcons.group,
    NotificationType.groupJoinRejected: AppIcons.group,
    NotificationType.unknown: AppIcons.bell,
  };

  test('covers every type', () {
    expect(expectedIcons.keys, unorderedEquals(NotificationType.values));
  });

  expectedIcons.forEach((type, icon) {
    test('${type.name} uses its icon', () {
      expect(notificationIconFor(type), icon);
    });
  });
}
