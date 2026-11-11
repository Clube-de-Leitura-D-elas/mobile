import 'package:cupertino_ui/cupertino_ui.dart'
    show GlobalCupertinoLocalizations;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/routes/app_route_observer.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/notifications/domain/entities/notifications_page_entity.dart';
import 'package:mobile/features/notifications/domain/repository/notification_repository.dart';
import 'package:mobile/features/notifications/presentation/cubit/notification_badge_cubit.dart';
import 'package:mobile/features/notifications/presentation/routes/notification_routes.dart';
import 'package:mobile/features/notifications/presentation/widgets/notification_bell.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockNotificationRepository extends Mock
    implements NotificationRepository {}

void main() {
  late MockNotificationRepository repository;

  void stubUnread(int count) {
    when(() => repository.getNotifications(page: 1)).thenAnswer(
      (_) async => Success(
        NotificationsPageEntity(items: const [], total: 0, unreadCount: count),
      ),
    );
  }

  setUp(() {
    repository = MockNotificationRepository();
  });

  Widget buildSubject() {
    final router = GoRouter(
      initialLocation: '/home',
      observers: [appRouteObserver],
      routes: [
        GoRoute(
          path: '/home',
          builder: (_, _) => BlocProvider(
            create: (_) =>
                NotificationBadgeCubit(repository: repository)..refresh(),
            child: const Scaffold(
              body: Align(
                alignment: Alignment.topRight,
                child: NotificationBell(),
              ),
            ),
          ),
        ),
        GoRoute(
          path: NotificationRoutes.notifications,
          builder: (context, _) => TextButton(
            onPressed: () => context.pop(),
            child: const Text('sair das notificações'),
          ),
        ),
      ],
    );

    return MaterialApp.router(
      theme: AppTheme.light,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt', 'BR'),
      routerConfig: router,
    );
  }

  testWidgets('hides the badge when nothing is unread', (tester) async {
    stubUnread(0);

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    final badge = tester.widget<Badge>(find.byType(Badge));
    expect(badge.isLabelVisible, isFalse);
    expect(find.byTooltip('Notificações'), findsOneWidget);
  });

  testWidgets('shows the unread count', (tester) async {
    stubUnread(3);

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(tester.widget<Badge>(find.byType(Badge)).isLabelVisible, isTrue);
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('caps the badge text at 99+', (tester) async {
    stubUnread(120);

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('99+'), findsOneWidget);
  });

  testWidgets('exposes a stable label with the count as value', (tester) async {
    final handle = tester.ensureSemantics();
    stubUnread(3);

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(
      tester.getSemantics(find.byType(NotificationBell)),
      isSemantics(
        label: 'Notificações',
        value: '3 não lidas',
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        hasTapAction: true,
      ),
    );

    tester.semantics.tap(find.semantics.byLabel('Notificações'));
    await tester.pumpAndSettle();

    expect(find.text('sair das notificações'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('has no semantic value when nothing is unread', (tester) async {
    final handle = tester.ensureSemantics();
    stubUnread(0);

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(
      tester.getSemantics(find.byType(NotificationBell)),
      isSemantics(label: 'Notificações', value: ''),
    );
    handle.dispose();
  });

  testWidgets('exposes a stable key for the automation', (tester) async {
    stubUnread(3);

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('notification-bell')));
    await tester.pumpAndSettle();

    expect(find.text('sair das notificações'), findsOneWidget);
  });

  testWidgets('has a 48x48 touch target', (tester) async {
    stubUnread(0);

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    final size = tester.getSize(find.byType(IconButton));
    expect(size.width, greaterThanOrEqualTo(48));
    expect(size.height, greaterThanOrEqualTo(48));
  });

  testWidgets('opens the notifications and refreshes when coming back', (
    tester,
  ) async {
    stubUnread(3);

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();
    await tester.tap(find.byType(IconButton));
    await tester.pumpAndSettle();

    expect(find.text('sair das notificações'), findsOneWidget);

    stubUnread(1);
    await tester.tap(find.text('sair das notificações'));
    await tester.pumpAndSettle();

    expect(find.text('1'), findsOneWidget);
    verify(() => repository.getNotifications(page: 1)).called(2);
  });

  testWidgets('refreshes when the app returns to the foreground', (
    tester,
  ) async {
    stubUnread(1);

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    stubUnread(4);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(find.text('4'), findsOneWidget);
  });
}
