import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/serviceLocator/service_locator.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/design_system/design_system.dart';
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
  });
}
