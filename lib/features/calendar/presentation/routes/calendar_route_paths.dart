import 'package:mobile/features/calendar/domain/entities/calendar_meeting_entity.dart';
import 'package:mobile/features/groups/presentation/routes/group_route_paths.dart';

abstract final class CalendarRoutePaths {
  /// Para onde o encontro leva; `null` quando ainda não há tela para ele.
  ///
  /// Só membro abre os detalhes do grupo. A tela de grupo para não-membro
  /// (CLU-287) ainda não existe; quando existir, a rota dela entra aqui.
  static String? destinationFor(CalendarMeetingEntity meeting) {
    final group = meeting.group;
    if (!group.isMember) return null;

    return Uri(
      path: GroupRoutePaths.groupDetails,
      queryParameters: {'group_id': group.id},
    ).toString();
  }
}
