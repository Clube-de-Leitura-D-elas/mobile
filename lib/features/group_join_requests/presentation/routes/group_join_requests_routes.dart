import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/routes/app_page_transitions.dart';
import 'package:mobile/core/serviceLocator/service_locator.dart';
import 'package:mobile/features/group_join_requests/presentation/cubit/group_join_requests_cubit.dart';
import 'package:mobile/features/group_join_requests/presentation/pages/group_join_requests_page.dart';
import 'package:mobile/features/group_join_requests/presentation/routes/group_join_requests_route_paths.dart';

abstract class GroupJoinRequestsRoutes {
  static const joinRequests = GroupJoinRequestsRoutePaths.joinRequests;

  static List<RouteBase> get routes => [
    GoRoute(
      path: joinRequests,
      pageBuilder: (context, state) {
        final groupId = state.uri.queryParameters['group_id'] ?? '';
        return AppPageTransitions.createPushPage(
          state: state,
          child: BlocProvider(
            create: (_) =>
                serviceLocator<GroupJoinRequestsCubit>()..load(groupId),
            child: const GroupJoinRequestsPage(),
          ),
        );
      },
    ),
  ];
}
