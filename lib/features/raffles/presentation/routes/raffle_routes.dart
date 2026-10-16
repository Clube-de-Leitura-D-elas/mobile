import 'package:go_router/go_router.dart';
import 'package:mobile/features/raffles/presentation/pages/raffle_preparation_page.dart';
import 'package:mobile/features/raffles/presentation/routes/raffle_route_paths.dart';

final List<RouteBase> raffleRoutes = [
  GoRoute(
    path: RaffleRoutePaths.preparation,
    builder: (context, state) {
      final meetingId = state.extra as String? ?? '';
      return RafflePreparationPage(meetingId: meetingId);
    },
  ),
];
