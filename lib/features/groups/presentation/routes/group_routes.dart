import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/routes/app_page_transitions.dart';
import 'package:mobile/core/serviceLocator/service_locator.dart';
import 'package:mobile/features/groups/presentation/cubit/group_details_cubit.dart';
import 'package:mobile/features/groups/presentation/cubit/event_history_cubit.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_details_cubit.dart';
import 'package:mobile/features/groups/presentation/pages/event_history_page.dart';
import 'package:mobile/features/groups/presentation/pages/group_details_page.dart';
import 'package:mobile/features/groups/presentation/pages/meeting_details_page.dart';
import 'package:mobile/features/groups/presentation/routes/group_route_paths.dart';

abstract class GroupRoutes {
  static const groupDetails = GroupRoutePaths.groupDetails;
  static const eventHistory = GroupRoutePaths.eventHistory;
  static const meetingDetails = GroupRoutePaths.meetingDetails;

  static List<RouteBase> get routes => [
    GoRoute(
      path: meetingDetails,
      pageBuilder: (context, state) {
        final meetingId = state.uri.queryParameters['meeting_id'] ?? '';
        return AppPageTransitions.createPushPage(
          state: state,
          child: BlocProvider(
            create: (_) =>
                serviceLocator<MeetingDetailsCubit>()..load(meetingId),
            child: const MeetingDetailsPage(),
          ),
        );
      },
    ),
    GoRoute(
      path: eventHistory,
      pageBuilder: (context, state) {
        final groupId = state.uri.queryParameters['group_id'] ?? '';
        return AppPageTransitions.createPushPage(
          state: state,
          child: BlocProvider(
            create: (_) => serviceLocator<EventHistoryCubit>()..load(groupId),
            child: const EventHistoryPage(),
          ),
        );
      },
    ),
    GoRoute(
      path: groupDetails,
      pageBuilder: (context, state) {
        final groupId = state.uri.queryParameters['group_id'] ?? '';
        return AppPageTransitions.createPushPage(
          state: state,
          child: BlocProvider(
            create: (_) => serviceLocator<GroupDetailsCubit>()..load(groupId),
            child: GroupDetailsPage(groupId: groupId),
          ),
        );
      },
    ),
  ];
}
