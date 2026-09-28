import 'package:go_router/go_router.dart';
import 'package:mobile/features/groups/presentation/pages/group_details_page.dart';

abstract class GroupRoutes {
  static const String groupDetails = '/group-details';

  static List<RouteBase> get routes => [
        GoRoute(
          path: groupDetails,
          builder: (context, state) {
            final groupId = state.uri.queryParameters['group_id'] ?? '';
            return GroupDetailsPage(groupId: groupId);
          },
        ),
      ];
}
