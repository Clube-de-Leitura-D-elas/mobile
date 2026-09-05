import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/features/auth/presentation/cubit/session_state.dart';
import 'package:mobile/features/auth/presentation/pages/claim_token_screen.dart';
import 'package:mobile/features/auth/presentation/pages/login_screen.dart';

abstract class AuthRoutes {
  static const String login = '/login';
  static const String claimToken = '/claim-token';

  static List<RouteBase> get routes => [
        GoRoute(
          path: login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: claimToken,
          builder: (context, state) {
            final userId = state.extra as String? ?? '';
            return ClaimTokenScreen(userId: userId);
          },
        ),
      ];

  /// Route guard for Auth feature.
  static String? authGuard(
    BuildContext context,
    GoRouterState state,
    SessionState sessionState,
  ) {
    final isLogin = state.matchedLocation == login;
    final isClaim = state.matchedLocation == claimToken;

    if (sessionState is LoadingSession) {
      return '/splash';
    }

    if (sessionState is AuthenticatedSession) {
      if (isLogin || isClaim) {
        return '/home';
      }
    }

    if (sessionState is NeedsClaimSession) {
      if (!isClaim) {
        return claimToken;
      }
    }

    if (sessionState is GuestSession) {
      if (isClaim) {
        return login;
      }
    }

    return null;
  }
}
