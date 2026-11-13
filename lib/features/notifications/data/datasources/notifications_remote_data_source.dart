import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile/core/supabase/supabase_failure.dart';
import 'package:mobile/core/supabase/supabase_service.dart';
import 'package:mobile/core/tools/result.dart';

abstract class NotificationsRemoteDataSource {
  Future<NotificationSettings> requestPermissions();
  Future<String?> getDeviceToken();
  Future<Result<void, SupabaseFailure>> saveTokenToBackend(String? token);
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
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
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
  Future<Result<void, SupabaseFailure>> saveTokenToBackend(
    String? token,
  ) async {
    final result = await _supabaseService.invokeFunction(
      functionName: 'save-fcm-token',
      body: {'fcm_token': token},
    );

    return switch (result) {
      Success() => const Success(null),
      Failure(:final failure) => Failure(failure),
    };
  }

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
  Stream<Map<String, dynamic>> get onNotificationOpened =>
      _onMessageOpenedApp.map((message) {
        if (kDebugMode) {
          debugPrint(
            '[NotificationsDataSource] Message opened from background: ${message.data}',
          );
        }
        return message.data;
      });

  @override
  Stream<Map<String, dynamic>> get onForegroundMessage =>
      _onMessage.map((message) {
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
