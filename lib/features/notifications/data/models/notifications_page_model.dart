import 'package:mobile/features/notifications/data/models/notification_model.dart';
import 'package:mobile/features/notifications/domain/entities/notifications_page_entity.dart';

class NotificationsPageModel {
  final List<NotificationModel> notifications;
  final int total;
  final int unreadCount;

  const NotificationsPageModel({
    required this.notifications,
    required this.total,
    required this.unreadCount,
  });

  factory NotificationsPageModel.fromJson(Map<String, dynamic> json) {
    final notifications = (json['notifications'] as List<dynamic>)
        .map((item) => NotificationModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return NotificationsPageModel(
      notifications: notifications,
      total: json['total'] as int,
      // A get-my-notifications ainda não devolve `unread_count`: até lá o
      // badge conta só as não lidas desta página.
      unreadCount:
          json['unread_count'] as int? ??
          notifications.where((item) => !item.isRead).length,
    );
  }

  NotificationsPageEntity toDomain() {
    return NotificationsPageEntity(
      items: notifications.map((item) => item.toDomain()).toList(),
      total: total,
      unreadCount: unreadCount,
    );
  }
}
