import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/notifications/domain/entities/notification_failure.dart';
import 'package:mobile/features/notifications/domain/repository/notification_repository.dart';

class SyncFcmTokenUseCase {
  final NotificationRepository repository;

  SyncFcmTokenUseCase({required this.repository});

  Future<Result<void, NotificationFailure>> execute() async {
    return await repository.syncDeviceToken();
  }
}
