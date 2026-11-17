import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/routes/app_page_transitions.dart';
import 'package:mobile/core/serviceLocator/service_locator.dart';
import 'package:mobile/features/auth/presentation/cubit/claim_token_cubit.dart';
import 'package:mobile/features/auth/presentation/cubit/session_state.dart';
import 'package:mobile/features/auth/presentation/pages/claim_token_screen.dart';
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
                create: (context) => serviceLocator<ClaimTokenCubit>(),
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
              create: (context) => serviceLocator<OnboardingReviewCubit>(),
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

    if (sessionState is AuthenticatedSession) {
      final cityId = sessionState.profile?.cityId;
      // Cidade nula é o sinal de revisão pendente. Zona depende da cidade
      // (nem toda cidade tem zonas), então o formulário valida esse caso.
      final reviewPending = cityId == null;

      if (reviewPending && !isReview) {
        return reviewProfile;
      }
      if (!reviewPending && isReview) {
        return '/home';
      }
    }

    return null;
  }
}
