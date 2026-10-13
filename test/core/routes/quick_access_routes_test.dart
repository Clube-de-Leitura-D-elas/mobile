import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/routes/quick_access_routes.dart';
import 'package:mobile/design_system/design_system.dart';

void main() {
  group('QuickAccessRoutes', () {
    test('maps every item to its corresponding path', () {
      expect(QuickAccessItem.values.map(QuickAccessRoutes.pathFor).toList(), [
        '/home',
        '/search',
        '/add',
        '/calendar',
        '/profile',
      ]);
    });

    test('identifies valid tab paths', () {
      for (final item in QuickAccessItem.values) {
        expect(
          QuickAccessRoutes.isTabPath(QuickAccessRoutes.pathFor(item)),
          isTrue,
        );
      }
    });

    test('rejects paths that are not tabs', () {
      expect(QuickAccessRoutes.isTabPath('/'), isFalse);
      expect(QuickAccessRoutes.isTabPath('/settings'), isFalse);
      expect(QuickAccessRoutes.isTabPath('/home/details'), isFalse);
      expect(QuickAccessRoutes.isTabPath(''), isFalse);
    });

    test('does not register a duplicate home route', () {
      final routes = QuickAccessRoutes.routes;

      expect(routes, hasLength(4));
      expect(routes.whereType<GoRoute>().map((route) => route.path), [
        '/search',
        '/add',
        '/calendar',
        '/profile',
      ]);
    });

    testWidgets('renders a placeholder with the selected tab', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const QuickAccessPlaceholderScreen(
            item: QuickAccessItem.calendar,
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(BottomNavigationBarWidget), findsOneWidget);

      final navigationBar = tester.widget<BottomNavigationBarWidget>(
        find.byType(BottomNavigationBarWidget),
      );

      expect(navigationBar.currentIndex, QuickAccessItem.calendar.index);
    });
  });
}
