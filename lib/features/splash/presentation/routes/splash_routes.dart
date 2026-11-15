import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/routes/app_page_transitions.dart';
import 'package:mobile/features/auth/presentation/cubit/session_state.dart';
import 'package:mobile/features/notifications/presentation/services/notification_navigation_service.dart';
import 'package:mobile/features/splash/presentation/pages/splash_screen.dart';

import 'package:mobile/features/onboarding/presentation/routes/onboarding_routes.dart';

abstract class SplashRoutes {
  static const String splash = '/splash';

  static List<RouteBase> get routes => [
        GoRoute(
          path: splash,
          pageBuilder: (context, state) => AppPageTransitions.createFadePage(
            state: state,
            child: const SplashScreen(),
          ),
        ),
      ];

  /// Route guard for Splash feature.
  static String? splashGuard(
    BuildContext context,
    GoRouterState state,
    SessionState sessionState,
  ) {
    final isSplash = state.matchedLocation == splash;

    // O erro de carregar o perfil (com "Tentar novamente") fica na splash.
    if (sessionState is SessionProfileUnavailable) {
      return isSplash ? null : splash;
    }

    if (isSplash) {
      if (sessionState is AuthenticatedSession) {
        final pendingRoute =
            NotificationNavigationService.consumePendingRoute();
        if (pendingRoute != null && pendingRoute.isNotEmpty) {
          return pendingRoute;
        }
        return '/home';
      }
      if (sessionState is NeedsClaimSession) {
        return OnboardingRoutes.claimToken;
      }
      if (sessionState is GuestSession) {
        return '/login';
      }
    }

    return null;
  }
}


