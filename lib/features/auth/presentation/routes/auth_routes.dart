import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/routes/app_page_transitions.dart';
import 'package:mobile/core/serviceLocator/service_locator.dart';
import 'package:mobile/features/auth/domain/repository/auth_repository.dart';
import 'package:mobile/features/auth/presentation/cubit/claim_token_cubit.dart';
import 'package:mobile/features/auth/presentation/cubit/session_state.dart';
import 'package:mobile/features/auth/presentation/pages/claim_token_screen.dart';
import 'package:mobile/features/auth/presentation/pages/login_screen.dart';
import 'package:mobile/features/auth/presentation/pages/register_screen.dart';

abstract class AuthRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String claimToken = '/claim-token';

  static List<RouteBase> get routes => [
        GoRoute(
          path: login,
          pageBuilder: (context, state) => AppPageTransitions.createFadePage(
            state: state,
            child: LoginScreen(
              onCreateAccountPressed: () => context.push(register),
            ),
          ),
        ),
        GoRoute(
          path: register,
          pageBuilder: (context, state) => AppPageTransitions.createPushPage(
            state: state,
            child: RegisterScreen(
              onLoginPressed: () => context.pop(),
            ),
          ),
        ),
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
      ];

  /// Route guard for Auth feature.
  static String? authGuard(
    BuildContext context,
    GoRouterState state,
    SessionState sessionState,
  ) {
    final isLogin = state.matchedLocation == login;
    final isRegister = state.matchedLocation == register;
    final isClaim = state.matchedLocation == claimToken;

    if (sessionState is LoadingSession) {
      // Avoid white screen redirect when performing auth loading on an active auth screen
      if (isLogin || isRegister || isClaim) {
        return null;
      }
      return '/splash';
    }

    if (sessionState is AuthenticatedSession) {
      if (isLogin || isRegister || isClaim) {
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
