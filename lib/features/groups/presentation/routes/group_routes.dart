import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/routes/app_page_transitions.dart';
import 'package:mobile/core/serviceLocator/service_locator.dart';
import 'package:mobile/features/groups/presentation/cubit/group_details_cubit.dart';
import 'package:mobile/features/groups/presentation/pages/group_details_page.dart';

abstract class GroupRoutes {
  static const String groupDetails = '/group-details';

  static List<RouteBase> get routes => [
    GoRoute(
      path: groupDetails,
      pageBuilder: (context, state) {
        final groupId = state.uri.queryParameters['group_id'] ?? '';
        return AppPageTransitions.createPushPage(
          state: state,
          child: BlocProvider(
            create: (_) => serviceLocator<GroupDetailsCubit>()..load(groupId),
            child: const GroupDetailsPage(),
          ),
        );
      },
    ),
  ];
}
