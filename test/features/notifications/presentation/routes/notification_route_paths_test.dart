import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/routes/quick_access_routes.dart';
import 'package:mobile/features/group_discovery/presentation/routes/group_discovery_route_paths.dart';
import 'package:mobile/features/group_join_requests/presentation/routes/group_join_requests_route_paths.dart';
import 'package:mobile/features/groups/presentation/routes/group_route_paths.dart';
import 'package:mobile/features/notifications/domain/entities/notification_entity.dart';
import 'package:mobile/features/notifications/domain/entities/notification_type.dart';
import 'package:mobile/features/notifications/presentation/routes/notification_route_paths.dart';

NotificationEntity _notification({
  String? meetingId,
  String? groupId,
  NotificationType type = NotificationType.meetingReminder,
}) {
  return NotificationEntity(
    id: 'n1',
    title: 'Título',
    message: 'Mensagem',
    type: type,
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

    for (final type in [
      NotificationType.meetingGuestApproved,
      NotificationType.meetingGuestRejected,
    ]) {
      test('${type.name} opens the calendar, not the member meeting '
          'details', () {
        expect(
          NotificationRoutePaths.destinationFor(
            _notification(meetingId: 'm1', groupId: 'g1', type: type),
          ),
          QuickAccessRoutes.calendar,
        );
      });
    }

    test('uses the group when there is no meeting', () {
      expect(
        NotificationRoutePaths.destinationFor(_notification(groupId: 'g1')),
        '${GroupRoutePaths.groupDetails}?group_id=g1',
      );
    });

    test('a rejected join request opens the public group page', () {
      expect(
        NotificationRoutePaths.destinationFor(
          _notification(
            groupId: 'g1',
            type: NotificationType.groupJoinRejected,
          ),
        ),
        '${GroupDiscoveryRoutePaths.publicGroup}?group_id=g1',
      );
    });

    test('a join request opens the coordinator join requests list', () {
      expect(
        NotificationRoutePaths.destinationFor(
          _notification(
            groupId: 'g1',
            type: NotificationType.groupJoinRequested,
          ),
        ),
        '${GroupJoinRequestsRoutePaths.joinRequests}?group_id=g1',
      );
    });

    test('an approved join request opens the public group page', () {
      expect(
        NotificationRoutePaths.destinationFor(
          _notification(
            groupId: 'g1',
            type: NotificationType.groupJoinApproved,
          ),
        ),
        GroupDiscoveryRoutePaths.publicGroupFor('g1'),
      );
    });

    test('returns null without a destination', () {
      expect(NotificationRoutePaths.destinationFor(_notification()), isNull);
    });
  });
}
