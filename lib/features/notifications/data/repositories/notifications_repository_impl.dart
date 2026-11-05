import 'package:flutter/foundation.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/notifications/data/datasources/notifications_remote_data_source.dart';
import 'package:mobile/features/notifications/domain/entities/notification_failure.dart';
import 'package:mobile/features/notifications/domain/repositories/notifications_repository.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsRemoteDataSource _remoteDataSource;

  NotificationsRepositoryImpl({
    required NotificationsRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<Result<void, NotificationFailure>> syncDeviceToken() async {
    try {
      await _remoteDataSource.requestPermissions();
      final token = await _remoteDataSource.getDeviceToken();

      if (token == null || token.isEmpty) {
        if (kDebugMode) {
          debugPrint('[NotificationsRepository] FCM token is null or empty, skipping sync.');
        }
        return const Success(null);
      }

      final result = await _remoteDataSource.saveTokenToBackend(token);
      return switch (result) {
        Success() => const Success(null),
        Failure(:final failure) => Failure(
            NotificationFailure(message: failure.message),
          ),
      };
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[NotificationsRepository] Unexpected error syncing FCM token: $e');
      }
      return Failure(NotificationFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void, NotificationFailure>> clearDeviceToken() async {
    try {
      final result = await _remoteDataSource.saveTokenToBackend(null);
      return switch (result) {
        Success() => const Success(null),
        Failure(:final failure) => Failure(
            NotificationFailure(message: failure.message),
          ),
      };
    } catch (e) {
      return Failure(NotificationFailure(message: e.toString()));
    }
  }

  @override
  Future<void> setupNotificationInteractions() async {
    await _remoteDataSource.setupNotificationInteractions();
  }

  @override
  Stream<String> get onTokenRefresh => _remoteDataSource.onTokenRefresh;
}
