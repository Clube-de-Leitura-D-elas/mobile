import 'package:go_router/go_router.dart';
import 'package:mobile/core/routes/app_page_transitions.dart';
import 'package:mobile/features/raffles/presentation/pages/raffle_execution_page.dart';
import 'package:mobile/features/raffles/presentation/pages/raffle_preparation_page.dart';
import 'package:mobile/features/raffles/presentation/routes/raffle_route_paths.dart';

abstract class RaffleRoutes {
  static const preparation = RaffleRoutePaths.preparation;
  static const draw = RaffleRoutePaths.draw;

  static List<RouteBase> get routes => [
    GoRoute(
      path: preparation,
      pageBuilder: (context, state) {
        final extra = state.extra;
        String meetingId = '';
        String meetingTitle = '';

        if (extra is String) {
          meetingId = extra;
        } else if (extra is Map<String, dynamic>) {
          meetingId = extra['meeting_id'] as String? ?? '';
          meetingTitle = extra['meeting_title'] as String? ?? '';
        } else {
          meetingId = state.uri.queryParameters['meeting_id'] ?? '';
          meetingTitle = state.uri.queryParameters['meeting_title'] ?? '';
        }

        return AppPageTransitions.createPushPage(
          state: state,
          child: RafflePreparationPage(
            meetingId: meetingId,
            meetingTitle: meetingTitle,
          ),
        );
      },
    ),
    GoRoute(
      path: draw,
      pageBuilder: (context, state) {
        final extra = state.extra;
        String meetingId = '';
        String meetingTitle = '';

        if (extra is String) {
          meetingId = extra;
        } else if (extra is Map<String, dynamic>) {
          meetingId = extra['meeting_id'] as String? ?? '';
          meetingTitle = extra['meeting_title'] as String? ?? '';
        } else {
          meetingId = state.uri.queryParameters['meeting_id'] ?? '';
          meetingTitle = state.uri.queryParameters['meeting_title'] ?? '';
        }

        return AppPageTransitions.createPushPage(
          state: state,
          child: RaffleExecutionPage(
            meetingId: meetingId,
            meetingTitle: meetingTitle,
          ),
        );
      },
    ),
  ];
}
