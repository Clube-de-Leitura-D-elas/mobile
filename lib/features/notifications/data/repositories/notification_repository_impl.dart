import 'package:flutter/foundation.dart';
import 'package:mobile/core/supabase/supabase_failure.dart';
import 'package:mobile/core/supabase/supabase_service.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/notifications/data/datasources/notifications_remote_data_source.dart';
import 'package:mobile/features/notifications/data/datasources/registered_token_store.dart';
import 'package:mobile/features/notifications/data/models/notifications_page_model.dart';
import 'package:mobile/features/notifications/domain/entities/notification_failure.dart';
import 'package:mobile/features/notifications/domain/entities/notifications_page_entity.dart';
import 'package:mobile/features/notifications/domain/repository/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl({
    required this.supabaseService,
    required this.registeredTokenStore,
    this.remoteDataSource,
  });

  final SupabaseService supabaseService;
  final NotificationsRemoteDataSource? remoteDataSource;

  /// Último token registrado no backend, guardado em disco. No logout, se o
  /// FCM não devolver o token atual (ou devolver outro, após uma rotação cujo
  /// re-sync falhou), é ele que o `unregister-device` também usa; sem isso o
  /// aparelho continuaria registrado e receberia push da conta que saiu.
  final RegisteredTokenStore registeredTokenStore;

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

      final result = await dataSource.registerDevice(token);
      switch (result) {
        case Success():
          await registeredTokenStore.save(token);
          return const Success(null);
        case Failure(:final failure):
          return Failure(_failureFrom(failure, const FcmTokenSyncFailure()));
      }
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

    // O `unregister-device` precisa do token deste aparelho. Se o FCM falhar
    // ao lê-lo, ainda dá para usar o último registrado.
    String? currentToken;
    try {
      currentToken = await dataSource.getDeviceToken();
    } catch (_) {
      currentToken = null;
    }

    // Desregistra os dois: se o FCM rotacionou o token e o re-sync falhou, o
    // que está no backend é o antigo, e o atual não está lá.
    final registeredToken = await registeredTokenStore.read();
    final tokens = <String>{
      if (currentToken != null && currentToken.isNotEmpty) currentToken,
      if (registeredToken != null && registeredToken.isNotEmpty)
        registeredToken,
    };

    // Sem nenhum token (o FCM não devolveu e nada foi registrado antes) não dá
    // para confirmar que o aparelho saiu do backend, então não vale `Success`.
    if (tokens.isEmpty) return const Failure(FcmTokenSyncFailure());

    Failure<void, NotificationFailure>? firstFailure;
    for (final token in tokens) {
      try {
        final result = await dataSource.unregisterDevice(token);
        switch (result) {
          case Success():
            if (token == registeredToken) await registeredTokenStore.clear();
          case Failure(:final failure):
            firstFailure ??= Failure(
              _failureFrom(failure, const FcmTokenSyncFailure()),
            );
        }
      } catch (_) {
        firstFailure ??= const Failure(FcmTokenSyncFailure());
      }
    }
    return firstFailure ?? const Success(null);
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
