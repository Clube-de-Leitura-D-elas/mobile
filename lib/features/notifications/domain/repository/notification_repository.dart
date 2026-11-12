import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/notifications/domain/entities/notification_failure.dart';
import 'package:mobile/features/notifications/domain/entities/notifications_page_entity.dart';

abstract class NotificationRepository {
  static const int pageSize = 20;

  /// [page] começa em 1. Mais recentes primeiro.
  Future<Result<NotificationsPageEntity, NotificationFailure>>
  getNotifications({required int page});

  Future<Result<void, NotificationFailure>> markAsRead(String notificationId);

  Future<Result<void, NotificationFailure>> syncDeviceToken();

  Future<Result<void, NotificationFailure>> clearDeviceToken();

  Future<Map<String, dynamic>?> getInitialNotificationData();

  Stream<Map<String, dynamic>> get onNotificationOpened;

  Stream<Map<String, dynamic>>? get onForegroundMessage => null;

  Stream<String> get onTokenRefresh;
}
