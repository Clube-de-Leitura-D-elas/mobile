import 'package:go_router/go_router.dart';
import 'package:mobile/core/routes/app_page_transitions.dart';
import 'package:mobile/features/raffles/presentation/pages/raffle_preparation_page.dart';
import 'package:mobile/features/raffles/presentation/routes/raffle_route_paths.dart';

abstract class RaffleRoutes {
  static const preparation = RaffleRoutePaths.preparation;

  static List<RouteBase> get routes => [
    GoRoute(
      path: preparation,
      pageBuilder: (context, state) {
        final meetingId =
            state.extra as String? ??
            state.uri.queryParameters['meeting_id'] ??
            '';
        return AppPageTransitions.createPushPage(
          state: state,
          child: RafflePreparationPage(meetingId: meetingId),
        );
      },
    ),
  ];
}

