import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/supabase/supabase_service.dart';
import 'package:mobile/features/auth/domain/entities/user_entity.dart';
import 'package:mobile/features/auth/domain/entities/user_profile_entity.dart';
import 'package:mobile/features/auth/domain/usecases/get_user_profile_use_case.dart';
import 'package:mobile/features/auth/domain/usecases/user_sign_in_use_case.dart';
import 'package:mobile/features/auth/domain/usecases/user_sign_in_with_email_use_case.dart';
import 'package:mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:mobile/features/auth/presentation/cubit/session_state.dart';
import 'package:mobile/features/auth/presentation/routes/auth_routes.dart';
import 'package:mobile/features/home/presentation/routes/home_routes.dart';
import 'package:mobile/features/splash/presentation/routes/splash_routes.dart';
import 'package:mocktail/mocktail.dart';

class MockUserSignInUseCase extends Mock implements UserSignInUseCase {}
class MockUserSignInWithEmailUseCase extends Mock implements UserSignInWithEmailUseCase {}
class MockGetUserProfileUseCase extends Mock implements GetUserProfileUseCase {}
class MockSupabaseService extends Mock implements SupabaseService {}

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
    final mockSignIn = MockUserSignInUseCase();
    final mockSignInEmail = MockUserSignInWithEmailUseCase();
    final mockGetProfile = MockGetUserProfileUseCase();
    final mockSupabase = MockSupabaseService();

    when(() => mockSupabase.currentUser).thenReturn(null);
    when(() => mockSupabase.authStateChanges)
        .thenAnswer((_) => const Stream.empty());

    sessionCubit = SessionCubit(
      userSignInUseCase: mockSignIn,
      userSignInWithEmailUseCase: mockSignInEmail,
      getUserProfileUseCase: mockGetProfile,
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
}

class FakeGoRouterState extends Fake implements GoRouterState {
  @override
  final String matchedLocation;

  FakeGoRouterState({required this.matchedLocation});
}

class FakeBuildContext extends Fake implements BuildContext {}
