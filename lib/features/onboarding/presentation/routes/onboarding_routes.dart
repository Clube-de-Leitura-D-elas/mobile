import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/routes/app_page_transitions.dart';
import 'package:mobile/core/serviceLocator/service_locator.dart';
import 'package:mobile/features/auth/domain/repository/auth_repository.dart';
import 'package:mobile/features/auth/presentation/cubit/claim_token_cubit.dart';
import 'package:mobile/features/auth/presentation/cubit/session_state.dart';
import 'package:mobile/features/auth/presentation/pages/claim_token_screen.dart';
import 'package:mobile/features/onboarding/domain/repository/onboarding_repository.dart';
import 'package:mobile/features/onboarding/presentation/cubit/onboarding_review_cubit.dart';
import 'package:mobile/features/onboarding/presentation/pages/onboarding_review_screen.dart';
import 'package:mobile/features/onboarding/presentation/pages/onboarding_welcome_screen.dart';

abstract class OnboardingRoutes {
  static const String claimToken = '/onboarding/claim';
  static const String reviewProfile = '/onboarding/review';
  static const String welcome = '/onboarding/welcome';

  static List<RouteBase> get routes => [
        GoRoute(
          path: claimToken,
          pageBuilder: (context, state) {
            final userId = state.extra as String? ?? '';
            return AppPageTransitions.createPushPage(
              state: state,
              child: BlocProvider(
                create: (context) => ClaimTokenCubit(
                  authRepository: serviceLocator<AuthRepository>(),
                ),
                child: ClaimTokenScreen(userId: userId),
              ),
            );
          },
        ),
        GoRoute(
          path: reviewProfile,
          pageBuilder: (context, state) => AppPageTransitions.createPushPage(
            state: state,
            child: BlocProvider(
              create: (context) => OnboardingReviewCubit(
                onboardingRepository: serviceLocator<OnboardingRepository>(),
              ),
              child: const OnboardingReviewScreen(),
            ),
          ),
        ),
        GoRoute(
          path: welcome,
          pageBuilder: (context, state) => AppPageTransitions.createFadePage(
            state: state,
            child: const OnboardingWelcomeScreen(),
          ),
        ),
      ];

  static String? onboardingGuard(
    BuildContext context,
    GoRouterState state,
    SessionState sessionState,
  ) {
    final isClaim = state.matchedLocation == claimToken;
    final isReview = state.matchedLocation == reviewProfile;
    final isWelcome = state.matchedLocation == welcome;

    if (sessionState is NeedsClaimSession) {
      if (!isClaim && !isReview && !isWelcome) {
        return claimToken;
      }
    }

    return null;
  }
}
