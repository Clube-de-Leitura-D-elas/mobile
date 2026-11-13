import 'package:mobile/core/routes/quick_access_routes.dart';
import 'package:mobile/features/group_discovery/presentation/routes/group_discovery_route_paths.dart';
import 'package:mobile/features/group_join_requests/presentation/routes/group_join_requests_route_paths.dart';
import 'package:mobile/features/groups/presentation/routes/group_route_paths.dart';
import 'package:mobile/features/notifications/domain/entities/notification_entity.dart';
import 'package:mobile/features/notifications/domain/entities/notification_type.dart';

abstract final class NotificationRoutePaths {
  static const notifications = '/notificacoes';

  /// Para onde a notificação leva; `null` quando ela não tem destino.
  static String? destinationFor(NotificationEntity notification) {
    // Vêm com `meeting_id`, mas a convidada não abre o detalhe de membro.
    if (notification.type == NotificationType.meetingGuestApproved ||
        notification.type == NotificationType.meetingGuestRejected) {
      return QuickAccessRoutes.calendar;
    }

    final meetingId = notification.meetingId;
    if (meetingId != null) {
      return Uri(
        path: GroupRoutePaths.meetingDetails,
        queryParameters: {'meeting_id': meetingId},
      ).toString();
    }

    final groupId = notification.groupId;
    // Aprovação e recusa vão para a tela pública, que mostra o vínculo atual:
    // quem saiu do grupo depois de aprovada levaria "sem permissão" no detalhe
    // de membro.
    if (groupId != null &&
        (notification.type == NotificationType.groupJoinApproved ||
            notification.type == NotificationType.groupJoinRejected)) {
      return GroupDiscoveryRoutePaths.publicGroupFor(groupId);
    }
    if (groupId != null &&
        notification.type == NotificationType.groupJoinRequested) {
      return GroupJoinRequestsRoutePaths.joinRequestsFor(groupId);
    }
    if (groupId != null) {
      return Uri(
        path: GroupRoutePaths.groupDetails,
        queryParameters: {'group_id': groupId},
      ).toString();
    }

    return null;
  }
}
