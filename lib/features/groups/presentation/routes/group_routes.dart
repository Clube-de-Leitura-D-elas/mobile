import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/routes/app_page_transitions.dart';
import 'package:mobile/core/serviceLocator/service_locator.dart';
import 'package:mobile/features/groups/presentation/cubit/group_details_cubit.dart';
import 'package:mobile/features/groups/presentation/cubit/event_history_cubit.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_details_cubit.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_photos_cubit.dart';
import 'package:mobile/features/groups/presentation/cubit/next_event_cubit.dart';
import 'package:mobile/features/groups/presentation/pages/event_history_page.dart';
import 'package:mobile/features/groups/presentation/cubit/group_participants_cubit.dart';
import 'package:mobile/features/groups/presentation/pages/group_details_page.dart';
import 'package:mobile/features/groups/presentation/pages/meeting_details_page.dart';
import 'package:mobile/features/groups/presentation/pages/meeting_edit_page.dart';
import 'package:mobile/features/groups/presentation/routes/group_route_paths.dart';
import 'package:mobile/features/groups/domain/entities/meeting_details_entity.dart';

abstract class GroupRoutes {
  static const groupDetails = GroupRoutePaths.groupDetails;
  static const eventHistory = GroupRoutePaths.eventHistory;
  static const meetingDetails = GroupRoutePaths.meetingDetails;
  static const meetingEdit = GroupRoutePaths.meetingEdit;

  static List<RouteBase> get routes => [
    GoRoute(
      path: meetingDetails,
      pageBuilder: (context, state) {
        final meetingId = state.uri.queryParameters['meeting_id'] ?? '';
        return AppPageTransitions.createPushPage(
          state: state,
          child: MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) =>
                    serviceLocator<MeetingDetailsCubit>()..load(meetingId),
              ),
              BlocProvider(
                create: (_) =>
                    serviceLocator<MeetingPhotosCubit>()..load(meetingId),
              ),
            ],
            child: const MeetingDetailsPage(),
          ),
        );
      },
    ),
    GoRoute(
      path: meetingEdit,
      pageBuilder: (context, state) {
        final meeting = state.extra;
        if (meeting is! MeetingDetailsEntity) {
          return AppPageTransitions.createPushPage(
            state: state,
            child: const Scaffold(body: SizedBox.shrink()),
          );
        }
        return AppPageTransitions.createPushPage(
          state: state,
          child: MeetingEditPage(meeting: meeting),
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
          child: MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) =>
                    serviceLocator<GroupDetailsCubit>()..load(groupId),
              ),
              BlocProvider(
                create: (_) => serviceLocator<NextEventCubit>()..load(groupId),
              ),
              BlocProvider(
                create: (_) =>
                    serviceLocator<GroupParticipantsCubit>()..load(groupId),
              ),
            ],
            child: GroupDetailsPage(groupId: groupId),
          ),
        );
      },
    ),
  ];
}
