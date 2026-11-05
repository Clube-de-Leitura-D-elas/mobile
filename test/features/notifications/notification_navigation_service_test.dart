import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/notifications/presentation/services/notification_navigation_service.dart';

void main() {
  setUp(() {
    NotificationNavigationService.pendingRoute = null;
  });

  group('NotificationNavigationService.parseRouteFromData', () {
    test('extracts explicit route if present in payload', () {
      final route = NotificationNavigationService.parseRouteFromData({
        'route': '/group-details?group_id=group-123',
      });

      expect(route, '/group-details?group_id=group-123');
    });

    test('extracts /group-details when screen and group_id are provided', () {
      final route = NotificationNavigationService.parseRouteFromData({
        'screen': '/group-details',
        'group_id': 'group-456',
      });

      expect(route, '/group-details?group_id=group-456');
    });

    test('extracts /group-details when only group_id is provided without meeting_id', () {
      final route = NotificationNavigationService.parseRouteFromData({
        'group_id': 'group-789',
      });

      expect(route, '/group-details?group_id=group-789');
    });

    test('extracts /meeting-details when meeting_id is provided', () {
      final route = NotificationNavigationService.parseRouteFromData({
        'meeting_id': 'meeting-123',
      });

      expect(route, '/meeting-details?meeting_id=meeting-123');
    });

    test('extracts screen starting with / if no explicit id is found', () {
      final route = NotificationNavigationService.parseRouteFromData({
        'screen': '/home',
      });

      expect(route, '/home');
    });

    test('returns null when payload is empty or invalid', () {
      final route = NotificationNavigationService.parseRouteFromData({});

      expect(route, isNull);
    });
  });

  group('NotificationNavigationService.handleNotificationClick & consumePendingRoute', () {
    test('saves pendingRoute on cold start', () {
      NotificationNavigationService.handleNotificationClick(
        {'route': '/group-details?group_id=test-group'},
        isColdStart: true,
      );

      expect(
        NotificationNavigationService.pendingRoute,
        '/group-details?group_id=test-group',
      );

      final consumed = NotificationNavigationService.consumePendingRoute();
      expect(consumed, '/group-details?group_id=test-group');
      expect(NotificationNavigationService.pendingRoute, isNull);
    });
  });
}
