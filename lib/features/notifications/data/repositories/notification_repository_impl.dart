import 'package:flutter/foundation.dart';
import 'package:mobile/core/supabase/supabase_failure.dart';
import 'package:mobile/core/supabase/supabase_service.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/notifications/data/datasources/notifications_remote_data_source.dart';
import 'package:mobile/features/notifications/data/models/notifications_page_model.dart';
import 'package:mobile/features/notifications/domain/entities/notification_failure.dart';
import 'package:mobile/features/notifications/domain/entities/notifications_page_entity.dart';
import 'package:mobile/features/notifications/domain/repository/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl({
    required this.supabaseService,
    this.remoteDataSource,
  });

  final SupabaseService supabaseService;
  final NotificationsRemoteDataSource? remoteDataSource;

  bool _permissionsRequested = false;

  @override
  Future<Result<NotificationsPageEntity, NotificationFailure>>
  getNotifications({required int page}) async {
    final result = await supabaseService.invokeFunction<NotificationsPageModel>(
      functionName: 'get-my-notifications',
      // A function lê a paginação da query string, não do body.
      queryParameters: {
        'page': '$page',
        'pageSize': '${NotificationRepository.pageSize}',
      },
      decoder: (data) =>
          NotificationsPageModel.fromJson(data as Map<String, dynamic>),
    );

    switch (result) {
      case Failure(:final failure):
        return Failure(_failureFrom(failure, const NotificationsLoadFailure()));
      case Success(:final data):
        final model = data.data;
        if (model == null) return const Failure(NotificationsLoadFailure());
        return Success(model.toDomain());
    }
  }

  @override
  Future<Result<void, NotificationFailure>> markAsRead(
    String notificationId,
  ) async {
    final result = await supabaseService.invokeFunction<void>(
      functionName: 'mark-notification-read',
      body: {'notification_id': notificationId},
    );

    return switch (result) {
      Failure(:final failure) => Failure(
        _failureFrom(failure, const NotificationMarkReadFailure()),
      ),
      Success() => const Success(null),
    };
  }

  @override
  Future<Result<void, NotificationFailure>> syncDeviceToken() async {
    final dataSource = remoteDataSource;
    if (dataSource == null) {
      return const Failure(FcmTokenSyncFailure());
    }

    try {
      if (!_permissionsRequested) {
        await dataSource.requestPermissions();
        _permissionsRequested = true;
      }

      final token = await dataSource.getDeviceToken();
      if (token == null || token.isEmpty) {
        if (kDebugMode) {
          debugPrint(
            '[NotificationRepository] FCM token is null or empty, skipping sync.',
          );
        }
        return const Success(null);
      }

      final result = await dataSource.saveTokenToBackend(token);
      return switch (result) {
        Success() => const Success(null),
        Failure(:final failure) => Failure(
          _failureFrom(failure, const FcmTokenSyncFailure()),
        ),
      };
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[NotificationRepository] Unexpected error syncing FCM token: $e',
        );
      }
      return const Failure(FcmTokenSyncFailure());
    }
  }

  @override
  Future<Result<void, NotificationFailure>> clearDeviceToken() async {
    _permissionsRequested = false;
    final dataSource = remoteDataSource;
    if (dataSource == null) {
      return const Failure(FcmTokenSyncFailure());
    }

    try {
      final result = await dataSource.saveTokenToBackend(null);
      return switch (result) {
        Success() => const Success(null),
        Failure(:final failure) => Failure(
          _failureFrom(failure, const FcmTokenSyncFailure()),
        ),
      };
    } catch (e) {
      return const Failure(FcmTokenSyncFailure());
    }
  }

  @override
  Future<Map<String, dynamic>?> getInitialNotificationData() async {
    return await remoteDataSource?.getInitialNotificationData();
  }

  @override
  Stream<Map<String, dynamic>> get onNotificationOpened =>
      remoteDataSource?.onNotificationOpened ?? const Stream.empty();

  @override
  Stream<Map<String, dynamic>>? get onForegroundMessage =>
      remoteDataSource?.onForegroundMessage;

  @override
  Stream<String> get onTokenRefresh =>
      remoteDataSource?.onTokenRefresh ?? const Stream.empty();

  NotificationFailure _failureFrom(
    SupabaseFailure failure,
    NotificationFailure fallback,
  ) {
    debugPrint('[NotificationFailure] ${failure.message} (${failure.code})');
    return switch (failure.kind) {
      SupabaseFailureKind.network => const NotificationNetworkFailure(),
      SupabaseFailureKind.unauthorized =>
        const NotificationSessionExpiredFailure(),
      _ => fallback,
    };
  }
}
