import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/routes/quick_access_routes.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/group_discovery/presentation/routes/group_discovery_route_paths.dart';
import 'package:mobile/features/group_join_requests/presentation/routes/group_join_requests_route_paths.dart';
import 'package:mobile/features/groups/presentation/routes/group_route_paths.dart';
import 'package:mobile/features/meeting_guest_requests/presentation/routes/meeting_guest_requests_route_paths.dart';
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

    test('a GROUP_JOIN_REQUESTED push opens the join requests list', () {
      final route = NotificationNavigationService.parseRouteFromData({
        'type': 'GROUP_JOIN_REQUESTED',
        'group_id': ' group-456 ',
      });
      expect(
        route,
        '${GroupJoinRequestsRoutePaths.joinRequests}?group_id=group-456',
      );
    });

    test('a GROUP_JOIN_REQUESTED push without group_id has no route', () {
      final route = NotificationNavigationService.parseRouteFromData({
        'type': 'GROUP_JOIN_REQUESTED',
      });
      expect(route, isNull);
    });

    test('a MEETING_GUEST_REQUESTED push opens the guest requests of the '
        'meeting', () {
      final route = NotificationNavigationService.parseRouteFromData({
        'type': 'MEETING_GUEST_REQUESTED',
        'meeting_id': ' meeting-789 ',
        'group_id': 'group-456',
      });
      expect(
        route,
        MeetingGuestRequestsRoutePaths.guestRequestsFor('meeting-789'),
      );
    });

    test('a MEETING_GUEST_REQUESTED push without meeting_id falls back to '
        'the group', () {
      final route = NotificationNavigationService.parseRouteFromData({
        'type': 'MEETING_GUEST_REQUESTED',
        'group_id': 'group-456',
      });
      expect(route, '${GroupRoutePaths.groupDetails}?group_id=group-456');
    });

    test('a GROUP_JOIN_APPROVED push opens the public group page', () {
      final route = NotificationNavigationService.parseRouteFromData({
        'type': 'GROUP_JOIN_APPROVED',
        'group_id': 'group-456',
      });
      expect(route, GroupDiscoveryRoutePaths.publicGroupFor('group-456'));
    });

    for (final type in ['MEETING_GUEST_APPROVED', 'MEETING_GUEST_REJECTED']) {
      test('a $type push opens the calendar even with meeting_id', () {
        final route = NotificationNavigationService.parseRouteFromData({
          'type': type,
          'meeting_id': 'meeting-789',
          'group_id': 'group-456',
        });
        expect(route, QuickAccessRoutes.calendar);
      });
    }

    // Mesma convenção dos GROUP_JOIN_*: `route` explícita do emissor vence
    // tudo; o tipo vence `screen` e `meeting_id`, porque a convidada não
    // abre o detalhe de membro.
    test('an explicit route wins over a MEETING_GUEST_* type', () {
      final route = NotificationNavigationService.parseRouteFromData({
        'type': 'MEETING_GUEST_APPROVED',
        'route': '/group-details?group_id=g1',
        'meeting_id': 'meeting-789',
      });
      expect(route, '/group-details?group_id=g1');
    });

    test('a MEETING_GUEST_* type wins over a meeting details screen', () {
      final route = NotificationNavigationService.parseRouteFromData({
        'type': 'MEETING_GUEST_REJECTED',
        'screen': 'meeting-details',
        'meeting_id': 'meeting-789',
      });
      expect(route, QuickAccessRoutes.calendar);
    });

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

  group('openNotificationRoute', () {
    Future<GoRouter> pumpRouter(WidgetTester tester) async {
      final router = GoRouter(
        initialLocation: '/start',
        routes: [
          for (final path in ['/start', QuickAccessRoutes.calendar, '/other'])
            GoRoute(path: path, builder: (_, _) => Text('page $path')),
        ],
      );
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      return router;
    }

    testWidgets('switches to a tab instead of stacking a second one', (
      tester,
    ) async {
      final router = await pumpRouter(tester);

      openNotificationRoute(router, QuickAccessRoutes.calendar);
      await tester.pumpAndSettle();

      expect(find.text('page ${QuickAccessRoutes.calendar}'), findsOneWidget);
      expect(router.canPop(), isFalse);
    });

    testWidgets('stacks any other destination', (tester) async {
      final router = await pumpRouter(tester);

      openNotificationRoute(router, '/other');
      await tester.pumpAndSettle();

      expect(find.text('page /other'), findsOneWidget);
      expect(router.canPop(), isTrue);
    });
  });
}
