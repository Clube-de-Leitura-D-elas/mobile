import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile/core/supabase/supabase_failure.dart';
import 'package:mobile/core/supabase/supabase_service.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/notifications/presentation/services/notification_navigation_service.dart';

abstract class NotificationsRemoteDataSource {
  Future<NotificationSettings> requestPermissions();
  Future<String?> getDeviceToken();
  Future<Result<void, SupabaseFailure>> saveTokenToBackend(String? token);
  Future<void> setupNotificationInteractions();
  Stream<String> get onTokenRefresh;
}

class NotificationsRemoteDataSourceImpl implements NotificationsRemoteDataSource {
  final FirebaseMessaging _messaging;
  final SupabaseService _supabaseService;

  NotificationsRemoteDataSourceImpl({
    FirebaseMessaging? messaging,
    required SupabaseService supabaseService,
  })  : _messaging = messaging ?? FirebaseMessaging.instance,
        _supabaseService = supabaseService;

  @override
  Future<NotificationSettings> requestPermissions() async {
    return await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
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
        debugPrint('[NotificationsDataSource] Error getting FCM token: $e\n$stackTrace');
      }
      return null;
    }
  }

  @override
  Future<Result<void, SupabaseFailure>> saveTokenToBackend(String? token) async {
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
  Future<void> setupNotificationInteractions() async {
    try {
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null && initialMessage.data.isNotEmpty) {
        if (kDebugMode) {
          debugPrint(
            '[NotificationsDataSource] Initial message opened: ${initialMessage.data}',
          );
        }
        NotificationNavigationService.handleNotificationClick(
          initialMessage.data,
          isColdStart: true,
        );
      }

      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        if (kDebugMode) {
          debugPrint(
            '[NotificationsDataSource] Message opened from background: ${message.data}',
          );
        }
        NotificationNavigationService.handleNotificationClick(
          message.data,
          isColdStart: false,
        );
      });
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '[NotificationsDataSource] Error setting up notification interactions: $e\n$stackTrace',
        );
      }
    }
  }

  @override
  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;
}
