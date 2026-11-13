import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/group_discovery/presentation/routes/group_discovery_route_paths.dart';
import 'package:mobile/features/groups/presentation/routes/group_route_paths.dart';
import 'package:mobile/features/notifications/domain/repository/notification_repository.dart';
import 'package:mobile/features/notifications/presentation/services/notification_navigation_service.dart';
import 'package:mocktail/mocktail.dart';

class MockNotificationRepository extends Mock
    implements NotificationRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    NotificationNavigationService.pendingRoute = null;
  });

  group('NotificationNavigationService', () {
    test('returns explicit route when provided in data', () {
      final route = NotificationNavigationService.parseRouteFromData({
        'route': '/group-details?group_id=abc-123',
      });
      expect(route, '/group-details?group_id=abc-123');
    });

    test('builds group details route from group_id', () {
      final route = NotificationNavigationService.parseRouteFromData({
        'screen': 'group-details',
        'group_id': 'group-456',
      });
      expect(route, '${GroupRoutePaths.groupDetails}?group_id=group-456');
    });

    test(
      'builds registered meeting details route (/detalhes/encontro) from meeting_id',
      () {
        final route = NotificationNavigationService.parseRouteFromData({
          'meeting_id': 'meeting-789',
        });
        expect(
          route,
          '${GroupRoutePaths.meetingDetails}?meeting_id=meeting-789',
        );
      },
    );

    test('a rejected join request push opens the public group page', () {
      final route = NotificationNavigationService.parseRouteFromData({
        'type': 'GROUP_JOIN_REJECTED',
        'group_id': ' group-456 ',
      });
      expect(
        route,
        '${GroupDiscoveryRoutePaths.publicGroup}?group_id=group-456',
      );
    });

    for (final type in ['GROUP_JOIN_REQUESTED', 'GROUP_JOIN_APPROVED']) {
      test('a $type push opens the member group details', () {
        final route = NotificationNavigationService.parseRouteFromData({
          'type': type,
          'group_id': 'group-456',
        });
        expect(route, '${GroupRoutePaths.groupDetails}?group_id=group-456');
      });
    }

    test('returns null when data is empty or invalid', () {
      final route = NotificationNavigationService.parseRouteFromData({});
      expect(route, isNull);
    });

    test('stores pendingRoute on cold start and consumes it once', () {
      NotificationNavigationService.handleNotificationClick({
        'group_id': 'group-999',
      }, isColdStart: true);

      expect(
        NotificationNavigationService.pendingRoute,
        '/group-details?group_id=group-999',
      );

      final consumed = NotificationNavigationService.consumePendingRoute();
      expect(consumed, '/group-details?group_id=group-999');
      expect(NotificationNavigationService.pendingRoute, isNull);
    });

    test(
      'setupInteractions registers onNotificationOpened even if getInitialNotificationData throws, and marks notification as read',
      () async {
        final repository = MockNotificationRepository();
        final openedController =
            StreamController<Map<String, dynamic>>.broadcast();
        addTearDown(openedController.close);

        when(
          () => repository.onNotificationOpened,
        ).thenAnswer((_) => openedController.stream);
        when(
          () => repository.getInitialNotificationData(),
        ).thenThrow(Exception('initial message failed'));
        when(
          () => repository.markAsRead('notif-1'),
        ).thenAnswer((_) async => const Success(null));

        await NotificationNavigationService.setupInteractions(repository);

        openedController.add({
          'notification_id': 'notif-1',
          'meeting_id': 'm-42',
        });
        await pumpEventQueue();

        expect(
          NotificationNavigationService.pendingRoute,
          '${GroupRoutePaths.meetingDetails}?meeting_id=m-42',
        );
        verify(() => repository.markAsRead('notif-1')).called(1);
      },
    );
  });
}
