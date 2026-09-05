import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:mobile/features/auth/presentation/cubit/session_state.dart';
import 'package:mobile/features/home/presentation/pages/home_screen.dart';

abstract class HomeRoutes {
  static const String home = '/home';

  static List<RouteBase> get routes => [
        GoRoute(
          path: home,
          builder: (context, state) {
            final sessionState = context.read<SessionCubit>().state;
            if (sessionState is AuthenticatedSession) {
              return HomeScreen(
                user: sessionState.user,
                profile: sessionState.profile,
              );
            }
            return const Scaffold(body: SizedBox.shrink());
          },
        ),
      ];

  /// Route guard for Home feature.
  static String? homeGuard(
    BuildContext context,
    GoRouterState state,
    SessionState sessionState,
  ) {
    final isHome = state.matchedLocation == home;

    if (isHome) {
      if (sessionState is! AuthenticatedSession) {
        if (sessionState is LoadingSession) {
          return '/splash';
        }
        if (sessionState is NeedsClaimSession) {
          return '/claim-token';
        }
        return '/login';
      }
    }

    return null;
  }
}
