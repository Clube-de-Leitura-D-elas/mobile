import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:mobile/features/auth/presentation/routes/auth_routes.dart';
import 'package:mobile/features/dropdown/presentation/routes/dropdown_route.dart';
import 'package:mobile/features/home/presentation/routes/home_routes.dart';
import 'package:mobile/features/splash/presentation/routes/splash_routes.dart';

/// Helper to convert a Stream into a Listenable for GoRouter refresh.
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();

    _subscription = stream.asBroadcastStream().listen(
          (_) => notifyListeners(),
        );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

abstract class AppRoutes {
  static GoRouter createRouter(SessionCubit sessionCubit) {
    return GoRouter(
      initialLocation: DropdownPreviewRoutes.dropdownPreview,
      refreshListenable: GoRouterRefreshStream(sessionCubit.stream),
      routes: [
        ...SplashRoutes.routes,
        ...AuthRoutes.routes,
        ...HomeRoutes.routes,
        ...DropdownPreviewRoutes.routes,
      ],
      redirect: (context, state) {
        final sessionState = sessionCubit.state;

        // Temporary route used only to test the Design System component.
        if (state.matchedLocation ==
            DropdownPreviewRoutes.dropdownPreview) {
          return null;
        }

        final splashRedirect = SplashRoutes.splashGuard(
          context,
          state,
          sessionState,
        );

        if (splashRedirect != null) {
          return splashRedirect;
        }

        final authRedirect = AuthRoutes.authGuard(
          context,
          state,
          sessionState,
        );

        if (authRedirect != null) {
          return authRedirect;
        }

        final homeRedirect = HomeRoutes.homeGuard(
          context,
          state,
          sessionState,
        );

        if (homeRedirect != null) {
          return homeRedirect;
        }

        return null;
      },
    );
  }
}