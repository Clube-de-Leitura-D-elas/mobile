import 'package:mobile/features/calendar/domain/entities/calendar_meeting_entity.dart';
import 'package:mobile/features/group_discovery/presentation/routes/group_discovery_route_paths.dart';
import 'package:mobile/features/groups/presentation/routes/group_route_paths.dart';

abstract final class CalendarRoutePaths {
  /// Membro abre os detalhes do grupo; os demais, a tela pública do grupo,
  /// onde podem pedir entrada.
  static String destinationFor(CalendarMeetingEntity meeting) {
    final group = meeting.group;
    if (!group.isMember) {
      return GroupDiscoveryRoutePaths.publicGroupFor(group.id);
    }

    return Uri(
      path: GroupRoutePaths.groupDetails,
      queryParameters: {'group_id': group.id},
    ).toString();
  }
}
