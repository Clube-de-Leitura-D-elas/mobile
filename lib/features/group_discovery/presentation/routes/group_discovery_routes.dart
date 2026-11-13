import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/routes/app_page_transitions.dart';
import 'package:mobile/core/serviceLocator/service_locator.dart';
import 'package:mobile/features/group_discovery/presentation/cubit/public_group_cubit.dart';
import 'package:mobile/features/group_discovery/presentation/pages/public_group_page.dart';
import 'package:mobile/features/group_discovery/presentation/routes/group_discovery_route_paths.dart';

abstract class GroupDiscoveryRoutes {
  static const publicGroup = GroupDiscoveryRoutePaths.publicGroup;

  static List<RouteBase> get routes => [
    GoRoute(
      path: publicGroup,
      pageBuilder: (context, state) {
        final groupId = state.uri.queryParameters['group_id'] ?? '';
        return AppPageTransitions.createPushPage(
          state: state,
          child: BlocProvider(
            create: (_) => serviceLocator<PublicGroupCubit>()..load(groupId),
            child: const PublicGroupPage(),
          ),
        );
      },
    ),
  ];
}
