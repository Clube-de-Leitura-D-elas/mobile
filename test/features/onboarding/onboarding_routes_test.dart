import 'package:bloc_test/bloc_test.dart';
import 'package:cupertino_ui/cupertino_ui.dart'
    show GlobalCupertinoLocalizations;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/serviceLocator/service_locator.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/auth/domain/entities/user_entity.dart';
import 'package:mobile/features/auth/domain/entities/user_profile_entity.dart';
import 'package:mobile/features/auth/domain/repository/auth_repository.dart';
import 'package:mobile/features/auth/presentation/cubit/claim_token_cubit.dart';
import 'package:mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:mobile/features/auth/presentation/cubit/session_state.dart';
import 'package:mobile/features/auth/presentation/pages/claim_token_screen.dart';
import 'package:mobile/features/onboarding/domain/entities/user_review_profile.dart';
import 'package:mobile/features/onboarding/domain/repository/onboarding_repository.dart';
import 'package:mobile/features/onboarding/presentation/cubit/onboarding_review_cubit.dart';
import 'package:mobile/features/onboarding/presentation/pages/onboarding_review_screen.dart';
import 'package:mobile/features/onboarding/presentation/pages/onboarding_welcome_screen.dart';
import 'package:mobile/features/onboarding/presentation/routes/onboarding_routes.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockOnboardingRepository extends Mock implements OnboardingRepository {}

class MockSessionCubit extends MockCubit<SessionState>
    implements SessionCubit {}

class MockBuildContext extends Mock implements BuildContext {}

class MockGoRouterState extends Mock implements GoRouterState {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockOnboardingRepository mockOnboardingRepository;
  late MockSessionCubit mockSessionCubit;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockOnboardingRepository = MockOnboardingRepository();
    mockSessionCubit = MockSessionCubit();

    when(() => mockSessionCubit.state).thenReturn(const GuestSession());
    when(() => mockSessionCubit.refreshProfile()).thenAnswer((_) async {});
    when(() => mockOnboardingRepository.getUserProfile()).thenAnswer(
      (_) async => const Success(UserReviewProfile(name: 'Maria')),
    );
    when(() => mockOnboardingRepository.getCitiesAndZones()).thenAnswer(
      (_) async => const Success([]),
    );

    serviceLocator.allowReassignment = true;
    serviceLocator.registerFactory<ClaimTokenCubit>(
      () => ClaimTokenCubit(authRepository: mockAuthRepository),
    );
    serviceLocator.registerFactory<OnboardingReviewCubit>(
      () => OnboardingReviewCubit(
        onboardingRepository: mockOnboardingRepository,
      ),
    );
  });

  tearDown(() {
    if (serviceLocator.isRegistered<ClaimTokenCubit>()) {
      serviceLocator.unregister<ClaimTokenCubit>();
    }
    if (serviceLocator.isRegistered<OnboardingReviewCubit>()) {
      serviceLocator.unregister<OnboardingReviewCubit>();
    }
  });

  Widget buildSubject(GoRouter router) {
    return BlocProvider<SessionCubit>.value(
      value: mockSessionCubit,
      child: MaterialApp.router(
        theme: AppTheme.light,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );
  }

  testWidgets(
    'builds ClaimTokenScreen via OnboardingRoutes.claimToken and resolves cubit',
    (tester) async {
      final router = GoRouter(
        initialLocation: OnboardingRoutes.claimToken,
        routes: OnboardingRoutes.routes,
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(buildSubject(router));
      await tester.pumpAndSettle();

      expect(find.byType(ClaimTokenScreen), findsOneWidget);
    },
  );

  testWidgets(
    'builds OnboardingReviewScreen via OnboardingRoutes.reviewProfile and resolves cubit',
    (tester) async {
      final router = GoRouter(
        initialLocation: OnboardingRoutes.reviewProfile,
        routes: OnboardingRoutes.routes,
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(buildSubject(router));
      await tester.pump();

      expect(find.byType(OnboardingReviewScreen), findsOneWidget);
    },
  );

  testWidgets(
    'builds OnboardingWelcomeScreen via OnboardingRoutes.welcome',
    (tester) async {
      final router = GoRouter(
        initialLocation: OnboardingRoutes.welcome,
        routes: OnboardingRoutes.routes,
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(buildSubject(router));
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingWelcomeScreen), findsOneWidget);
    },
  );

  group('onboardingGuard', () {
    final mockContext = MockBuildContext();
    final mockState = MockGoRouterState();

    AuthenticatedSession authenticated({
      String? cityId,
      String? zoneId,
    }) {
      return AuthenticatedSession(
        user: const UserEntity(
          name: 'Maria',
          mail: 'maria@example.com',
          birthday: '1990-01-01',
          phoneNumber: '51999999999',
          instagramUser: '',
          educationDegree: '',
          jobPosition: '',
          cityZone: (id: '', name: '', acronym: ''),
        ),
        profile: UserProfileEntity(
          id: 'p-1',
          name: 'Maria',
          email: 'maria@example.com',
          address: '',
          phoneNumber: '51999999999',
          birthday: '1990-01-01',
          instagram: '',
          educationDegree: '',
          jobPosition: '',
          userId: 'u-1',
          isActive: true,
          cityId: cityId,
          zoneId: zoneId,
        ),
      );
    }

    test('redirects to claimToken if NeedsClaimSession and not on an onboarding route', () {
      when(() => mockState.matchedLocation).thenReturn('/home');

      expect(
        OnboardingRoutes.onboardingGuard(
          mockContext,
          mockState,
          const NeedsClaimSession(userId: 'u1'),
        ),
        equals(OnboardingRoutes.claimToken),
      );
    });

    test('returns null if NeedsClaimSession and already on claimToken, reviewProfile, or welcome', () {
      when(() => mockState.matchedLocation).thenReturn(OnboardingRoutes.claimToken);
      expect(
        OnboardingRoutes.onboardingGuard(
          mockContext,
          mockState,
          const NeedsClaimSession(userId: 'u1'),
        ),
        isNull,
      );

      when(() => mockState.matchedLocation).thenReturn(OnboardingRoutes.reviewProfile);
      expect(
        OnboardingRoutes.onboardingGuard(
          mockContext,
          mockState,
          const NeedsClaimSession(userId: 'u1'),
        ),
        isNull,
      );

      when(() => mockState.matchedLocation).thenReturn(OnboardingRoutes.welcome);
      expect(
        OnboardingRoutes.onboardingGuard(
          mockContext,
          mockState,
          const NeedsClaimSession(userId: 'u1'),
        ),
        isNull,
      );
    });

    test('returns null when sessionState is not NeedsClaimSession', () {
      when(() => mockState.matchedLocation).thenReturn('/any');
      expect(
        OnboardingRoutes.onboardingGuard(
          mockContext,
          mockState,
          const GuestSession(),
        ),
        isNull,
      );
    });

    test('redirects to reviewProfile when authenticated without city', () {
      when(() => mockState.matchedLocation).thenReturn('/home');

      expect(
        OnboardingRoutes.onboardingGuard(
          mockContext,
          mockState,
          authenticated(),
        ),
        equals(OnboardingRoutes.reviewProfile),
      );
    });

    test('leaves reviewProfile while the city is missing', () {
      when(() => mockState.matchedLocation).thenReturn(
        OnboardingRoutes.reviewProfile,
      );

      expect(
        OnboardingRoutes.onboardingGuard(
          mockContext,
          mockState,
          authenticated(),
        ),
        isNull,
      );
    });

    test('does not redirect when only the zone is missing', () {
      when(() => mockState.matchedLocation).thenReturn('/home');

      expect(
        OnboardingRoutes.onboardingGuard(
          mockContext,
          mockState,
          authenticated(cityId: 'city-1'),
        ),
        isNull,
      );
    });

    test('leaves reviewProfile when only the zone is missing', () {
      when(() => mockState.matchedLocation).thenReturn(
        OnboardingRoutes.reviewProfile,
      );

      expect(
        OnboardingRoutes.onboardingGuard(
          mockContext,
          mockState,
          authenticated(cityId: 'city-1'),
        ),
        equals('/home'),
      );
    });

    test('does not show reviewProfile after city and zone are set', () {
      when(() => mockState.matchedLocation).thenReturn(
        OnboardingRoutes.reviewProfile,
      );

      expect(
        OnboardingRoutes.onboardingGuard(
          mockContext,
          mockState,
          authenticated(cityId: 'city-1', zoneId: 'zone-1'),
        ),
        equals('/home'),
      );
    });

    test('allows home after city and zone are set', () {
      when(() => mockState.matchedLocation).thenReturn('/home');

      expect(
        OnboardingRoutes.onboardingGuard(
          mockContext,
          mockState,
          authenticated(cityId: 'city-1', zoneId: 'zone-1'),
        ),
        isNull,
      );
    });
  });
}
