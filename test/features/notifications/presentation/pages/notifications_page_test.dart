import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/presentation/routes/group_route_paths.dart';
import 'package:mobile/features/notifications/domain/entities/notification_entity.dart';
import 'package:mobile/features/notifications/domain/entities/notification_type.dart';
import 'package:mobile/features/notifications/domain/entities/notification_failure.dart';
import 'package:mobile/features/notifications/domain/entities/notifications_page_entity.dart';
import 'package:mobile/features/notifications/domain/repository/notification_repository.dart';
import 'package:mobile/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:mobile/features/notifications/presentation/pages/notifications_page.dart';
import 'package:mobile/features/notifications/presentation/routes/notification_routes.dart';
import 'package:mobile/features/notifications/presentation/widgets/notification_tile.dart';
import 'package:mobile/features/notifications/presentation/widgets/notifications_skeleton.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockNotificationRepository extends Mock
    implements NotificationRepository {}

NotificationEntity _notification(
  String id, {
  bool isRead = false,
  NotificationType type = NotificationType.meetingReminder,
  String? meetingId,
  String? groupId,
  Duration age = const Duration(hours: 2),
}) {
  return NotificationEntity(
    id: id,
    title: 'Título $id',
    message: 'Mensagem $id',
    type: type,
    date: DateTime.now().subtract(age),
    isRead: isRead,
    meetingId: meetingId,
    groupId: groupId,
  );
}

void main() {
  late MockNotificationRepository repository;

  setUp(() {
    repository = MockNotificationRepository();
    when(
      () => repository.markAsRead(any()),
    ).thenAnswer((_) async => const Success(null));
  });

  void stubPage(int page, List<NotificationEntity> items, {int? total}) {
    when(() => repository.getNotifications(page: page)).thenAnswer(
      (_) async => Success(
        NotificationsPageEntity(
          items: items,
          total: total ?? items.length,
          unreadCount: 0,
        ),
      ),
    );
  }

  Widget buildSubject() {
    final router = GoRouter(
      initialLocation: NotificationRoutes.notifications,
      routes: [
        GoRoute(
          path: NotificationRoutes.notifications,
          builder: (_, _) => BlocProvider(
            create: (_) => NotificationsCubit(repository: repository)..load(),
            child: const NotificationsPage(),
          ),
        ),
        for (final path in [
          GroupRoutePaths.meetingDetails,
          GroupRoutePaths.groupDetails,
        ])
          GoRoute(
            path: path,
            builder: (_, state) => Text('destino: ${state.uri}'),
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

  group('states', () {
    testWidgets('shows the skeleton while loading', (tester) async {
      final pending =
          Completer<Result<NotificationsPageEntity, NotificationFailure>>();
      when(
        () => repository.getNotifications(page: 1),
      ).thenAnswer((_) => pending.future);

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.byType(NotificationsSkeleton), findsOneWidget);
      expect(find.bySemanticsLabel('Carregando notificações'), findsOneWidget);
    });

    testWidgets('shows the empty message', (tester) async {
      stubPage(1, []);

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      final message = find.text('Nenhuma notificação por aqui');
      expect(message, findsOneWidget);
      expect(
        tester.widget<Text>(message).style?.color,
        tester.element(message).colors.textMuted,
      );
      expect(find.text('Tentar novamente'), findsNothing);
    });

    testWidgets('shows the error and reloads on retry', (tester) async {
      when(
        () => repository.getNotifications(page: 1),
      ).thenAnswer((_) async => const Failure(NotificationsLoadFailure()));

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(
        find.text('Não foi possível carregar suas notificações.'),
        findsOneWidget,
      );

      expect(
        tester.getSize(find.byType(AppButton)).height,
        greaterThanOrEqualTo(48),
      );

      stubPage(1, [_notification('n1')]);
      await tester.tap(find.text('Tentar novamente'));
      await tester.pumpAndSettle();

      expect(find.text('Título n1'), findsOneWidget);
      verify(() => repository.getNotifications(page: 1)).called(2);
    });
  });

  group('list', () {
    testWidgets('renders title, message, relative date and unread mark', (
      tester,
    ) async {
      stubPage(1, [
        _notification('n1'),
        _notification('n2', isRead: true, age: const Duration(days: 1)),
      ]);

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Título n1'), findsOneWidget);
      expect(find.text('Mensagem n1'), findsOneWidget);
      expect(find.text('há 2 h'), findsOneWidget);
      expect(find.text('ontem'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('n1')),
          matching: find.byKey(const Key('notification-unread-dot')),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('n2')),
          matching: find.byKey(const Key('notification-unread-dot')),
        ),
        findsNothing,
      );
    });

    testWidgets('picks the icon by type and falls back for unknown ones', (
      tester,
    ) async {
      stubPage(1, [
        _notification('n1', type: NotificationType.bookSuggestionsReminder),
        _notification('n2', type: NotificationType.unknown),
      ]);

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      AppIconAsset iconOf(String id) => tester
          .widget<AppIcon>(
            find.descendant(
              of: find.byKey(ValueKey(id)),
              matching: find.byType(AppIcon),
            ),
          )
          .icon;

      expect(iconOf('n1'), AppIcons.book);
      expect(iconOf('n2'), AppIcons.bell);
    });

    testWidgets('exposes read state and tap to semantics', (tester) async {
      final handle = tester.ensureSemantics();
      stubPage(1, [_notification('n1')]);

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      const label = 'Não lida: Título n1. Mensagem n1';
      expect(
        tester.getSemantics(find.byType(NotificationTile)),
        isSemantics(
          label: label,
          value: 'há 2 h',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
        ),
      );

      tester.semantics.tap(find.semantics.byLabel(label));
      await tester.pumpAndSettle();

      verify(() => repository.markAsRead('n1')).called(1);
      expect(find.bySemanticsLabel('Título n1. Mensagem n1'), findsOneWidget);
      handle.dispose();
    });
  });

  testWidgets('keeps the end of the list above the system bar', (tester) async {
    tester.view
      ..devicePixelRatio = 1
      ..padding = const FakeViewPadding(bottom: 34);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);
    stubPage(1, [_notification('n1')]);

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(NotificationTile));
    final padding = tester.widget<ListView>(find.byType(ListView)).padding;

    expect(
      padding?.resolve(TextDirection.ltr).bottom,
      context.spacing.s16 + 34,
    );
  });

  group('infinite scroll', () {
    final firstPage = List.generate(
      NotificationRepository.pageSize,
      (index) => _notification('n$index'),
    );

    testWidgets('loads the next page only when the end gets close', (
      tester,
    ) async {
      stubPage(1, firstPage, total: 21);
      stubPage(2, [_notification('last')], total: 21);

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      verifyNever(() => repository.getNotifications(page: 2));

      await tester.scrollUntilVisible(
        find.text('Título last'),
        300,
        scrollable: find.byType(Scrollable),
      );

      expect(find.text('Título last'), findsOneWidget);
      verify(() => repository.getNotifications(page: 2)).called(1);
    });

    testWidgets('fetches the next page when the first does not fill the '
        'screen', (tester) async {
      stubPage(1, [_notification('n1')], total: 25);
      stubPage(2, [_notification('n2')], total: 25);

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Título n2'), findsOneWidget);
    });

    testWidgets('offers a retry when the next page fails', (tester) async {
      stubPage(1, [_notification('n1')], total: 25);
      when(
        () => repository.getNotifications(page: 2),
      ).thenAnswer((_) async => const Failure(NotificationsLoadFailure()));

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(
        find.text('Não foi possível carregar mais notificações.'),
        findsOneWidget,
      );
      expect(find.text('Título n1'), findsOneWidget);
      expect(
        tester.getSize(find.byType(AppButton)).height,
        greaterThanOrEqualTo(48),
      );

      stubPage(2, [_notification('n2')], total: 21);
      await tester.tap(find.text('Tentar novamente'));
      await tester.pumpAndSettle();

      expect(find.text('Título n2'), findsOneWidget);
      verify(() => repository.getNotifications(page: 1)).called(1);
      verify(() => repository.getNotifications(page: 2)).called(2);
    });
  });

  group('tap', () {
    testWidgets('marks as read and opens the meeting', (tester) async {
      stubPage(1, [_notification('n1', meetingId: 'm1', groupId: 'g1')]);

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      await tester.tap(find.byType(NotificationTile));
      await tester.pumpAndSettle();

      verify(() => repository.markAsRead('n1')).called(1);
      expect(
        find.text('destino: ${GroupRoutePaths.meetingDetails}?meeting_id=m1'),
        findsOneWidget,
      );
    });

    testWidgets('opens the group when there is no meeting', (tester) async {
      stubPage(1, [_notification('n1', groupId: 'g1')]);

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      await tester.tap(find.byType(NotificationTile));
      await tester.pumpAndSettle();

      expect(
        find.text('destino: ${GroupRoutePaths.groupDetails}?group_id=g1'),
        findsOneWidget,
      );
    });

    testWidgets('only marks as read when there is no destination', (
      tester,
    ) async {
      stubPage(1, [_notification('n1')]);

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      await tester.tap(find.byType(NotificationTile));
      await tester.pumpAndSettle();

      verify(() => repository.markAsRead('n1')).called(1);
      expect(find.byType(NotificationsPage), findsOneWidget);
      expect(find.byKey(const Key('notification-unread-dot')), findsNothing);
    });

    testWidgets('restores the unread mark when marking fails', (tester) async {
      stubPage(1, [_notification('n1')]);
      when(
        () => repository.markAsRead('n1'),
      ).thenAnswer((_) async => const Failure(NotificationMarkReadFailure()));

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      await tester.tap(find.byType(NotificationTile));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('notification-unread-dot')), findsOneWidget);
    });

    testWidgets('does not mark a read notification again', (tester) async {
      stubPage(1, [_notification('n1', isRead: true, groupId: 'g1')]);

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      await tester.tap(find.byType(NotificationTile));
      await tester.pumpAndSettle();

      verifyNever(() => repository.markAsRead(any()));
      expect(find.textContaining('destino:'), findsOneWidget);
    });
  });
}
