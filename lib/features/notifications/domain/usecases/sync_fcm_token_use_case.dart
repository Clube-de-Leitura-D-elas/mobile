import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/notifications/domain/entities/notification_failure.dart';
import 'package:mobile/features/notifications/domain/repositories/notifications_repository.dart';

class SyncFcmTokenUseCase {
  final NotificationsRepository repository;

  SyncFcmTokenUseCase({required this.repository});

  Future<Result<void, NotificationFailure>> execute() async {
    return await repository.syncDeviceToken();
  }
}
