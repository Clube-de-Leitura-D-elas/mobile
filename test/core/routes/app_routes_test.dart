import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/routes/app_routes.dart';
import 'package:mobile/core/serviceLocator/service_locator.dart';
import 'package:mobile/core/supabase/supabase_service.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/auth/domain/entities/user_entity.dart';
import 'package:mobile/features/auth/domain/entities/user_profile_entity.dart';
import 'package:mobile/features/auth/domain/repository/auth_repository.dart';
import 'package:mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:mobile/features/auth/presentation/cubit/session_state.dart';
import 'package:mobile/features/auth/presentation/routes/auth_routes.dart';
import 'package:mobile/features/groups/domain/entities/group_entity.dart';
import 'package:mobile/features/groups/domain/repository/group_repository.dart';
import 'package:mobile/features/home/presentation/cubit/home_cubit.dart';
import 'package:mobile/features/home/presentation/pages/home_screen.dart';
import 'package:mobile/features/home/presentation/routes/home_routes.dart';
import 'package:mobile/features/notifications/domain/entities/notifications_page_entity.dart';
import 'package:mobile/features/notifications/domain/repository/notification_repository.dart';
import 'package:mobile/features/notifications/presentation/cubit/notification_badge_cubit.dart';
import 'package:mobile/features/splash/presentation/routes/splash_routes.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockSupabaseService extends Mock implements SupabaseService {}

class MockSessionCubit extends MockCubit<SessionState>
    implements SessionCubit {}

class MockGroupRepository extends Mock implements GroupRepository {}

class MockNotificationRepository extends Mock
    implements NotificationRepository {}

void main() {
  late SessionCubit sessionCubit;

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

  const testProfile = UserProfileEntity(
    id: '1',
    name: 'User',
    email: 'user@example.com',
    address: 'Address',
    phoneNumber: '123',
    birthday: '01/01/2000',
    instagram: '@user',
    educationDegree: 'Degree',
    jobPosition: 'Dev',
    userId: 'user-1',
    isActive: true,
  );

  setUp(() {
    final mockAuthRepo = MockAuthRepository();
    final mockSupabase = MockSupabaseService();

    when(() => mockSupabase.currentUser).thenReturn(null);
    when(() => mockSupabase.authStateChanges)
        .thenAnswer((_) => const Stream.empty());

    sessionCubit = SessionCubit(
      authRepository: mockAuthRepo,
      supabaseService: mockSupabase,
    );
  });

  tearDown(() {
    sessionCubit.close();
  });

  group('Route Guards', () {
    test('homeGuard redirects to /login when session is GuestSession', () {
      final mockState = FakeGoRouterState(matchedLocation: HomeRoutes.home);
      final redirect = HomeRoutes.homeGuard(
        FakeBuildContext(),
        mockState,
        const GuestSession(),
      );

      expect(redirect, equals(AuthRoutes.login));
    });

    test('homeGuard allows navigation to /home when session is AuthenticatedSession', () {
      final mockState = FakeGoRouterState(matchedLocation: HomeRoutes.home);
      final redirect = HomeRoutes.homeGuard(
        FakeBuildContext(),
        mockState,
        const AuthenticatedSession(user: testUser, profile: testProfile),
      );

      expect(redirect, isNull);
    });

    test('authGuard redirects to /home when authenticated and visiting /login', () {
      final mockState = FakeGoRouterState(matchedLocation: AuthRoutes.login);
      final redirect = AuthRoutes.authGuard(
        FakeBuildContext(),
        mockState,
        const AuthenticatedSession(user: testUser, profile: testProfile),
      );

      expect(redirect, equals(HomeRoutes.home));
    });

    test('splashGuard redirects to /login when guest visits /splash', () {
      final mockState = FakeGoRouterState(matchedLocation: SplashRoutes.splash);
      final redirect = SplashRoutes.splashGuard(
        FakeBuildContext(),
        mockState,
        const GuestSession(),
      );

      expect(redirect, equals(AuthRoutes.login));
    });

    test('splashGuard redirects to /home when authenticated user visits /splash', () {
      final mockState = FakeGoRouterState(matchedLocation: SplashRoutes.splash);
      final redirect = SplashRoutes.splashGuard(
        FakeBuildContext(),
        mockState,
        const AuthenticatedSession(user: testUser, profile: testProfile),
      );

      expect(redirect, equals(HomeRoutes.home));
    });
  });

  group('Unknown route', () {
    late MockSessionCubit authenticatedSessionCubit;

    setUp(() {
      authenticatedSessionCubit = MockSessionCubit();
      whenListen(
        authenticatedSessionCubit,
        const Stream<SessionState>.empty(),
        initialState: const AuthenticatedSession(
          user: testUser,
          profile: testProfile,
        ),
      );

      final groupRepository = MockGroupRepository();
      when(
        () => groupRepository.getMyGroups(),
      ).thenAnswer((_) async => const Success(<GroupEntity>[]));
      final notificationRepository = MockNotificationRepository();
      when(() => notificationRepository.getNotifications(page: 1)).thenAnswer(
        (_) async => const Success(
          NotificationsPageEntity(items: [], total: 0, unreadCount: 0),
        ),
      );

      serviceLocator.allowReassignment = true;
      serviceLocator.registerFactory<HomeCubit>(
        () => HomeCubit(groupRepository: groupRepository),
      );
      serviceLocator.registerFactory<NotificationBadgeCubit>(
        () => NotificationBadgeCubit(repository: notificationRepository),
      );
    });

    tearDown(() {
      if (serviceLocator.isRegistered<HomeCubit>()) {
        serviceLocator.unregister<HomeCubit>();
      }
      if (serviceLocator.isRegistered<NotificationBadgeCubit>()) {
        serviceLocator.unregister<NotificationBadgeCubit>();
      }
    });

    testWidgets('shows AppErrorState and goes home from the button', (
      tester,
    ) async {
      final router = AppRoutes.createRouter(authenticatedSessionCubit);
      addTearDown(router.dispose);

      await tester.pumpWidget(
        BlocProvider<SessionCubit>.value(
          value: authenticatedSessionCubit,
          child: MaterialApp.router(
            theme: AppTheme.light,
            locale: const Locale('pt'),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              ...GlobalMaterialLocalizations.delegates,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      router.go('/rota-inexistente');
      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(AppErrorState, 'Página não encontrada.'),
        findsOneWidget,
      );

      await tester.tap(find.text('Ir para o início'));
      await tester.pumpAndSettle();

      expect(find.byType(AppErrorState), findsNothing);
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(
        router.routerDelegate.currentConfiguration.uri.path,
        HomeRoutes.home,
      );
    });
  });
}

class FakeGoRouterState extends Fake implements GoRouterState {
  @override
  final String matchedLocation;

  FakeGoRouterState({required this.matchedLocation});
}

class FakeBuildContext extends Fake implements BuildContext {}
