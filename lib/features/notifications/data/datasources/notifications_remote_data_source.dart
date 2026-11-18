import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile/core/supabase/supabase_failure.dart';
import 'package:mobile/core/supabase/supabase_service.dart';
import 'package:mobile/core/tools/result.dart';

abstract class NotificationsRemoteDataSource {
  Future<NotificationSettings> requestPermissions();
  Future<String?> getDeviceToken();
  Future<Result<void, SupabaseFailure>> registerDevice(String token);
  Future<Result<void, SupabaseFailure>> unregisterDevice(String token);
  Future<Map<String, dynamic>?> getInitialNotificationData();
  Stream<Map<String, dynamic>> get onNotificationOpened;
  Stream<Map<String, dynamic>> get onForegroundMessage;
  Stream<String> get onTokenRefresh;
}

class NotificationsRemoteDataSourceImpl
    implements NotificationsRemoteDataSource {
  final FirebaseMessaging? _customMessaging;
  final SupabaseService _supabaseService;
  final Stream<RemoteMessage>? _customOnMessageOpenedApp;
  final Stream<RemoteMessage>? _customOnMessage;

  NotificationsRemoteDataSourceImpl({
    FirebaseMessaging? messaging,
    required SupabaseService supabaseService,
    Stream<RemoteMessage>? onMessageOpenedApp,
    Stream<RemoteMessage>? onMessage,
  }) : _customMessaging = messaging,
       _supabaseService = supabaseService,
       _customOnMessageOpenedApp = onMessageOpenedApp,
       _customOnMessage = onMessage;

  FirebaseMessaging get _messaging =>
      _customMessaging ?? FirebaseMessaging.instance;

  Stream<RemoteMessage> get _onMessageOpenedApp =>
      _customOnMessageOpenedApp ?? FirebaseMessaging.onMessageOpenedApp;

  Stream<RemoteMessage> get _onMessage =>
      _customOnMessage ?? FirebaseMessaging.onMessage;

  @override
  Future<NotificationSettings> requestPermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    // Com o app aberto o push do sistema não aparece: só o sino é atualizado
    // (via `onForegroundMessage`).
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: false,
      sound: false,
    );
    return settings;
  }

  @override
  Future<String?> getDeviceToken() async {
    try {
      final token = await _messaging.getToken();
      if (kDebugMode) {
        debugPrint('[NotificationsDataSource] FCM Token retrieved: $token');
      }
      return token;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '[NotificationsDataSource] Error getting FCM token: $e\n$stackTrace',
        );
      }
      rethrow;
    }
  }

  @override
  Future<Result<void, SupabaseFailure>> registerDevice(String token) {
    return _invokeDeviceFunction('register-device', {
      'fcm_token': token,
      'platform': _platform,
    });
  }

  @override
  Future<Result<void, SupabaseFailure>> unregisterDevice(String token) {
    return _invokeDeviceFunction('unregister-device', {'fcm_token': token});
  }

  /// As duas functions de aparelho só devolvem sucesso ou falha, sem corpo útil.
  Future<Result<void, SupabaseFailure>> _invokeDeviceFunction(
    String functionName,
    Map<String, dynamic> body,
  ) async {
    final result = await _supabaseService.invokeFunction(
      functionName: functionName,
      body: body,
    );

    return switch (result) {
      Success() => const Success(null),
      Failure(:final failure) => Failure(failure),
    };
  }

  /// O backend só aceita `ANDROID` ou `IOS` (contrato do `register-device`).
  String get _platform =>
      defaultTargetPlatform == TargetPlatform.iOS ? 'IOS' : 'ANDROID';

  @override
  Future<Map<String, dynamic>?> getInitialNotificationData() async {
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage == null || initialMessage.data.isEmpty) {
      return null;
    }
    if (kDebugMode) {
      debugPrint(
        '[NotificationsDataSource] Initial message opened: ${initialMessage.data}',
      );
    }
    return initialMessage.data;
  }

  @override
  Stream<Map<String, dynamic>>
  get onNotificationOpened => _onMessageOpenedApp.map((message) {
    if (kDebugMode) {
      debugPrint(
        '[NotificationsDataSource] Message opened from background: ${message.data}',
      );
    }
    return message.data;
  });

  @override
  Stream<Map<String, dynamic>> get onForegroundMessage => _onMessage.map((
    message,
  ) {
    if (kDebugMode) {
      debugPrint(
        '[NotificationsDataSource] Foreground message received: ${message.data}',
      );
    }
    return message.data;
  });

  @override
  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;
}
