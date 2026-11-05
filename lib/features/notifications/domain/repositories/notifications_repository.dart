import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/notifications/domain/entities/notification_failure.dart';

abstract class NotificationsRepository {
  Future<Result<void, NotificationFailure>> syncDeviceToken();
  Future<Result<void, NotificationFailure>> clearDeviceToken();
  Future<void> setupNotificationInteractions();
  Stream<String> get onTokenRefresh;
}
