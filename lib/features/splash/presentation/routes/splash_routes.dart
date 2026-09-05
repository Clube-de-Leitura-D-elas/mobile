import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/features/auth/presentation/cubit/session_state.dart';
import 'package:mobile/features/splash/presentation/pages/splash_screen.dart';

abstract class SplashRoutes {
  static const String splash = '/splash';

  static List<RouteBase> get routes => [
        GoRoute(
          path: splash,
          builder: (context, state) => const SplashScreen(),
        ),
      ];

  /// Route guard for Splash feature.
  static String? splashGuard(
    BuildContext context,
    GoRouterState state,
    SessionState sessionState,
  ) {
    final isSplash = state.matchedLocation == splash;

    if (isSplash) {
      if (sessionState is AuthenticatedSession) {
        return '/home';
      }
      if (sessionState is NeedsClaimSession) {
        return '/claim-token';
      }
      if (sessionState is GuestSession) {
        return '/login';
      }
    }

    return null;
  }
}
