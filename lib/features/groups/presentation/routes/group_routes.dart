import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/routes/app_page_transitions.dart';
import 'package:mobile/core/serviceLocator/service_locator.dart';
import 'package:mobile/features/groups/domain/entities/meeting_details_entity.dart';
import 'package:mobile/features/groups/presentation/cubit/event_history_cubit.dart';
import 'package:mobile/features/groups/presentation/cubit/group_details_cubit.dart';
import 'package:mobile/features/groups/presentation/cubit/group_participants_cubit.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_details_cubit.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_edit_cubit.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_photos_cubit.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_tasks_cubit.dart';
import 'package:mobile/features/groups/presentation/cubit/next_event_cubit.dart';
import 'package:mobile/features/groups/presentation/cubit/place_search_cubit.dart';
import 'package:mobile/features/groups/presentation/pages/event_history_page.dart';
import 'package:mobile/features/groups/presentation/pages/group_details_page.dart';
import 'package:mobile/features/groups/presentation/pages/meeting_attendance_page.dart';
import 'package:mobile/features/groups/presentation/pages/meeting_details_page.dart';
import 'package:mobile/features/groups/presentation/pages/meeting_edit_page.dart';
import 'package:mobile/features/groups/presentation/pages/meeting_edit_route_page.dart';
import 'package:mobile/features/groups/presentation/pages/meeting_tasks_screen.dart';
import 'package:mobile/features/groups/presentation/routes/group_route_paths.dart';

abstract class GroupRoutes {
  static const groupDetails = GroupRoutePaths.groupDetails;
  static const eventHistory = GroupRoutePaths.eventHistory;
  static const meetingDetails = GroupRoutePaths.meetingDetails;
  static const meetingAttendance = GroupRoutePaths.meetingAttendance;
  static const meetingEdit = GroupRoutePaths.meetingEdit;
  static const meetingTasks = GroupRoutePaths.meetingTasks;
  static const meetingRecord = GroupRoutePaths.meetingRecord;

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
            child: BlocProvider(
              create: (_) =>
                  serviceLocator<MeetingDetailsCubit>()
                    ..load(state.uri.queryParameters['meeting_id'] ?? ''),
              child: const MeetingEditRoutePage(),
            ),
          );
        }
        return AppPageTransitions.createPushPage(
          state: state,
          child: MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => serviceLocator<MeetingEditCubit>()),
              BlocProvider(create: (_) => serviceLocator<PlaceSearchCubit>()),
            ],
            child: MeetingEditPage(meeting: meeting),
          ),
        );
      },
    ),
    GoRoute(
      path: meetingRecord,
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
    GoRoute(
      path: meetingAttendance,
      pageBuilder: (context, state) {
        final meetingId = state.uri.queryParameters['meeting_id'] ?? '';
        final extra = state.extra as Map<String, dynamic>?;

        return AppPageTransitions.createPushPage(
          state: state,
          child: MeetingAttendancePage(
            meetingId: meetingId,
            meetingName: extra?['meetingName'] as String? ?? '',
            formattedDate: extra?['formattedDate'] as String? ?? '',
            concludeOnFinish: extra?['concludeOnFinish'] as bool? ?? false,
          ),
        );
      },
    ),
    GoRoute(
      path: meetingTasks,
      pageBuilder: (context, state) {
        final meetingId = state.uri.queryParameters['meeting_id'];
        return AppPageTransitions.createPushPage(
          state: state,
          child: meetingId == null || meetingId.isEmpty
              ? const Scaffold(body: Center(child: Text('Encontro inválido.')))
              : BlocProvider(
                  create: (_) => MeetingTasksCubit(
                    groupRepository: serviceLocator(),
                    meetingId: meetingId,
                  )..load(),
                  child: MeetingTasksScreen(meetingId: meetingId),
                ),
        );
      },
    ),
  ];
}
