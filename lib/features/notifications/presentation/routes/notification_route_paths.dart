import 'package:mobile/features/groups/presentation/routes/group_route_paths.dart';
import 'package:mobile/features/notifications/domain/entities/notification_entity.dart';

abstract final class NotificationRoutePaths {
  static const notifications = '/notificacoes';

  /// Para onde a notificação leva; `null` quando ela não tem destino.
  static String? destinationFor(NotificationEntity notification) {
    final meetingId = notification.meetingId;
    if (meetingId != null) {
      return Uri(
        path: GroupRoutePaths.meetingDetails,
        queryParameters: {'meeting_id': meetingId},
      ).toString();
    }

    final groupId = notification.groupId;
    if (groupId != null) {
      return Uri(
        path: GroupRoutePaths.groupDetails,
        queryParameters: {'group_id': groupId},
      ).toString();
    }

    return null;
  }
}
