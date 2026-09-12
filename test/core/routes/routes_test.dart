import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/routes/app_routes.dart';
import 'package:mobile/core/serviceLocator/service_locator.dart';
import 'package:mobile/core/supabase/supabase_service.dart';
import 'package:mobile/features/auth/domain/entities/user_entity.dart';
import 'package:mobile/features/auth/domain/entities/user_profile_entity.dart';
import 'package:mobile/features/auth/domain/repository/auth_repository.dart';
import 'package:mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:mobile/features/auth/presentation/cubit/session_state.dart';
import 'package:mobile/features/auth/presentation/routes/auth_routes.dart';
import 'package:mobile/features/home/presentation/routes/home_routes.dart';
import 'package:mobile/features/splash/presentation/routes/splash_routes.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockSupabaseService extends Mock implements SupabaseService {}
class MockBuildContext extends Mock implements BuildContext {}
class MockGoRouterState extends Mock implements GoRouterState {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthRepository mockAuthRepository;
  late MockSupabaseService mockSupabaseService;
  late SessionCubit sessionCubit;
  late MockBuildContext mockContext;
  late MockGoRouterState mockState;

  const testUser = UserEntity(
    name: 'Test',
    mail: 'test@example.com',
    birthday: '01/01/2000',
    phoneNumber: '123',
    instagramUser: '@test',
    educationDegree: 'Degree',
    jobPosition: 'Dev',
    cityZone: (id: '', name: '', acronym: ''),
  );

  const testProfile = UserProfileEntity(
    id: '1',
    name: 'Test',
    email: 'test@example.com',
    address: 'Addr',
    phoneNumber: '123',
    birthday: '01/01/2000',
    instagram: '@test',
    educationDegree: 'Degree',
    jobPosition: 'Dev',
    userId: 'u1',
    isActive: true,
  );

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockSupabaseService = MockSupabaseService();
    mockContext = MockBuildContext();
    mockState = MockGoRouterState();

    when(() => mockSupabaseService.currentUser).thenReturn(null);
    when(() => mockSupabaseService.authStateChanges)
        .thenAnswer((_) => const Stream.empty());

    sessionCubit = SessionCubit(
      authRepository: mockAuthRepository,
      supabaseService: mockSupabaseService,
    );
  });

  tearDown(() {
    sessionCubit.close();
  });

  group('GoRouterRefreshStream', () {
    test('notifies listeners on stream event and cancels on dispose', () async {
      final controller = StreamController<int>();
      final refreshStream = GoRouterRefreshStream(controller.stream);

      int notifiedCount = 0;
      refreshStream.addListener(() {
        notifiedCount++;
      });

      controller.add(1);
      await pumpEventQueue();

      expect(notifiedCount, greaterThan(0));

      refreshStream.dispose();
      await controller.close();
    });
  });

  group('AppRoutes', () {
    test('createRouter builds router successfully', () {
      final router = AppRoutes.createRouter(sessionCubit);
      expect(router, isA<GoRouter>());
    });

    testWidgets('executes builders for splash, login, claimToken, and home routes', (tester) async {
      serviceLocator.allowReassignment = true;
      serviceLocator.registerFactory<AuthRepository>(() => mockAuthRepository);

      final router = AppRoutes.createRouter(sessionCubit);
      await tester.pumpWidget(
        BlocProvider<SessionCubit>.value(
          value: sessionCubit,
          child: MaterialApp.router(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      router.go(AuthRoutes.login);
      await tester.pumpAndSettle();

      router.go(AuthRoutes.claimToken, extra: 'user-123');
      await tester.pumpAndSettle();

      router.go(HomeRoutes.home);
      await tester.pumpAndSettle();
    });
  });

  group('SplashRoutes', () {
    test('splashGuard redirects correctly based on SessionState', () {
      when(() => mockState.matchedLocation).thenReturn(SplashRoutes.splash);

      expect(
        SplashRoutes.splashGuard(mockContext, mockState, const AuthenticatedSession(user: testUser, profile: testProfile)),
        equals('/home'),
      );

      expect(
        SplashRoutes.splashGuard(mockContext, mockState, const NeedsClaimSession(userId: 'u1')),
        equals('/claim-token'),
      );

      expect(
        SplashRoutes.splashGuard(mockContext, mockState, const GuestSession()),
        equals('/login'),
      );

      expect(
        SplashRoutes.splashGuard(mockContext, mockState, const LoadingSession()),
        isNull,
      );
    });
  });

  group('AuthRoutes', () {
    test('authGuard redirects correctly based on SessionState', () {
      when(() => mockState.matchedLocation).thenReturn('/other');

      expect(
        AuthRoutes.authGuard(mockContext, mockState, const LoadingSession()),
        equals('/splash'),
      );

      when(() => mockState.matchedLocation).thenReturn(AuthRoutes.login);
      expect(
        AuthRoutes.authGuard(mockContext, mockState, const AuthenticatedSession(user: testUser, profile: testProfile)),
        equals('/home'),
      );

      when(() => mockState.matchedLocation).thenReturn('/login');
      expect(
        AuthRoutes.authGuard(mockContext, mockState, const NeedsClaimSession(userId: 'u1')),
        equals(AuthRoutes.claimToken),
      );

      when(() => mockState.matchedLocation).thenReturn(AuthRoutes.claimToken);
      expect(
        AuthRoutes.authGuard(mockContext, mockState, const GuestSession()),
        equals(AuthRoutes.login),
      );

      when(() => mockState.matchedLocation).thenReturn(AuthRoutes.login);
      expect(
        AuthRoutes.authGuard(mockContext, mockState, const GuestSession()),
        isNull,
      );
    });
  });

  group('HomeRoutes', () {
    test('homeGuard redirects correctly based on SessionState', () {
      when(() => mockState.matchedLocation).thenReturn(HomeRoutes.home);

      expect(
        HomeRoutes.homeGuard(mockContext, mockState, const LoadingSession()),
        equals('/splash'),
      );

      expect(
        HomeRoutes.homeGuard(mockContext, mockState, const NeedsClaimSession(userId: 'u1')),
        equals('/claim-token'),
      );

      expect(
        HomeRoutes.homeGuard(mockContext, mockState, const GuestSession()),
        equals('/login'),
      );

      expect(
        HomeRoutes.homeGuard(mockContext, mockState, const AuthenticatedSession(user: testUser, profile: testProfile)),
        isNull,
      );

      when(() => mockState.matchedLocation).thenReturn('/other');
      expect(
        HomeRoutes.homeGuard(mockContext, mockState, const GuestSession()),
        isNull,
      );
    });
  });
}
