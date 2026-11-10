import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/groups/presentation/routes/group_route_paths.dart';
import 'package:mobile/features/notifications/domain/entities/notification_entity.dart';
import 'package:mobile/features/notifications/domain/entities/notification_type.dart';
import 'package:mobile/features/notifications/presentation/routes/notification_route_paths.dart';

NotificationEntity _notification({String? meetingId, String? groupId}) {
  return NotificationEntity(
    id: 'n1',
    title: 'Título',
    message: 'Mensagem',
    type: NotificationType.meetingReminder,
    date: DateTime.utc(2026, 11, 5),
    isRead: false,
    meetingId: meetingId,
    groupId: groupId,
  );
}

void main() {
  group('NotificationRoutePaths.destinationFor', () {
    test('prefers the meeting over the group', () {
      expect(
        NotificationRoutePaths.destinationFor(
          _notification(meetingId: 'm1', groupId: 'g1'),
        ),
        '${GroupRoutePaths.meetingDetails}?meeting_id=m1',
      );
    });

    test('uses the group when there is no meeting', () {
      expect(
        NotificationRoutePaths.destinationFor(_notification(groupId: 'g1')),
        '${GroupRoutePaths.groupDetails}?group_id=g1',
      );
    });

    test('returns null without a destination', () {
      expect(NotificationRoutePaths.destinationFor(_notification()), isNull);
    });
  });
}
