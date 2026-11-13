import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/routes/app_page_transitions.dart';
import 'package:mobile/core/serviceLocator/service_locator.dart';
import 'package:mobile/features/meeting_guest_requests/presentation/cubit/meeting_guest_requests_cubit.dart';
import 'package:mobile/features/meeting_guest_requests/presentation/pages/meeting_guest_requests_page.dart';
import 'package:mobile/features/meeting_guest_requests/presentation/routes/meeting_guest_requests_route_paths.dart';

abstract class MeetingGuestRequestsRoutes {
  static const guestRequests = MeetingGuestRequestsRoutePaths.guestRequests;

  static List<RouteBase> get routes => [
    GoRoute(
      path: guestRequests,
      pageBuilder: (context, state) {
        final meetingId = state.uri.queryParameters['meeting_id'] ?? '';
        return AppPageTransitions.createPushPage(
          state: state,
          child: BlocProvider(
            create: (_) =>
                serviceLocator<MeetingGuestRequestsCubit>()..load(meetingId),
            child: const MeetingGuestRequestsPage(),
          ),
        );
      },
    ),
  ];
}
