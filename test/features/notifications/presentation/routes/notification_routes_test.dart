import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/routes/app_routes.dart';
import 'package:mobile/core/serviceLocator/service_locator.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/auth/domain/entities/user_entity.dart';
import 'package:mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:mobile/features/auth/presentation/cubit/session_state.dart';
import 'package:mobile/features/groups/domain/entities/group_entity.dart';
import 'package:mobile/features/groups/domain/repository/group_repository.dart';
import 'package:mobile/features/home/presentation/cubit/home_cubit.dart';
import 'package:mobile/features/home/presentation/pages/home_screen.dart';
import 'package:mobile/features/notifications/domain/entities/notification_entity.dart';
import 'package:mobile/features/notifications/domain/entities/notification_type.dart';
import 'package:mobile/features/notifications/domain/entities/notifications_page_entity.dart';
import 'package:mobile/features/notifications/domain/repository/notification_repository.dart';
import 'package:mobile/features/notifications/presentation/cubit/notification_badge_cubit.dart';
import 'package:mobile/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:mobile/features/notifications/presentation/pages/notifications_page.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockGroupRepository extends Mock implements GroupRepository {}

class MockNotificationRepository extends Mock
    implements NotificationRepository {}

class MockSessionCubit extends MockCubit<SessionState>
    implements SessionCubit {}

void main() {
  const testUser = UserEntity(
    name: 'User',
    mail: 'user@example.com',
    birthday: '01/01/2000',
    phoneNumber: '123',
    instagramUser: '@user',
    educationDegree: 'Degree',
    jobPosition: 'Dev',
    cityZone: (id: '', name: '', acronym: ''),
  );

  final notification = NotificationEntity(
    id: 'n1',
    title: 'Encontro amanhã',
    message: 'Não esqueça do livro',
    type: NotificationType.meetingReminder,
    date: DateTime.utc(2026, 11, 5),
    isRead: false,
  );

  late MockNotificationRepository repository;

  void stubUnread(int count) {
    when(() => repository.getNotifications(page: 1)).thenAnswer(
      (_) async => Success(
        NotificationsPageEntity(
          items: [notification],
          total: 1,
          unreadCount: count,
        ),
      ),
    );
  }

  setUp(() {
    repository = MockNotificationRepository();
    final groupRepository = MockGroupRepository();
    when(
      () => groupRepository.getMyGroups(),
    ).thenAnswer((_) async => const Success(<GroupEntity>[]));

    serviceLocator
      ..allowReassignment = true
      ..registerFactory<HomeCubit>(
        () => HomeCubit(groupRepository: groupRepository),
      )
      ..registerFactory<NotificationBadgeCubit>(
        () => NotificationBadgeCubit(repository: repository),
      )
      ..registerFactory<NotificationsCubit>(
        () => NotificationsCubit(repository: repository),
      );
  });

  tearDown(() {
    serviceLocator
      ..unregister<HomeCubit>()
      ..unregister<NotificationBadgeCubit>()
      ..unregister<NotificationsCubit>();
  });

  testWidgets('the app router opens the list and refreshes the badge on back', (
    tester,
  ) async {
    final sessionCubit = MockSessionCubit();
    whenListen(
      sessionCubit,
      const Stream<SessionState>.empty(),
      initialState: const AuthenticatedSession(user: testUser),
    );
    stubUnread(3);

    final router = AppRoutes.createRouter(sessionCubit);
    addTearDown(router.dispose);

    await tester.pumpWidget(
      BlocProvider<SessionCubit>.value(
        value: sessionCubit,
        child: MaterialApp.router(
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
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('3'), findsOneWidget);

    await tester.tap(find.byTooltip('Notificações'));
    await tester.pumpAndSettle();

    expect(find.byType(NotificationsPage), findsOneWidget);
    expect(find.text('Encontro amanhã'), findsOneWidget);

    stubUnread(1);
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.byType(NotificationsPage), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
