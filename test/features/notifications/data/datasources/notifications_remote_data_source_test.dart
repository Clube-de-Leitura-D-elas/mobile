import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/supabase/supabase_failure.dart';
import 'package:mobile/core/supabase/supabase_response.dart';
import 'package:mobile/core/supabase/supabase_service.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/notifications/data/datasources/notifications_remote_data_source.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseMessaging extends Mock implements FirebaseMessaging {}

class MockSupabaseService extends Mock implements SupabaseService {}

class FakeNotificationSettings extends Fake implements NotificationSettings {}

void main() {
  late MockFirebaseMessaging mockMessaging;
  late MockSupabaseService mockSupabaseService;
  late StreamController<RemoteMessage> openedController;
  late StreamController<RemoteMessage> foregroundController;
  late NotificationsRemoteDataSourceImpl dataSource;

  setUp(() {
    mockMessaging = MockFirebaseMessaging();
    mockSupabaseService = MockSupabaseService();
    openedController = StreamController<RemoteMessage>.broadcast();
    foregroundController = StreamController<RemoteMessage>.broadcast();

    dataSource = NotificationsRemoteDataSourceImpl(
      messaging: mockMessaging,
      supabaseService: mockSupabaseService,
      onMessageOpenedApp: openedController.stream,
      onMessage: foregroundController.stream,
    );
  });

  tearDown(() async {
    await openedController.close();
    await foregroundController.close();
  });

  group('NotificationsRemoteDataSourceImpl', () {
    group('registerDevice', () {
      tearDown(() => debugDefaultTargetPlatformOverride = null);

      test('invokes register-device with fcm_token and ANDROID', () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        when(
          () => mockSupabaseService.invokeFunction<dynamic>(
            functionName: 'register-device',
            body: {'fcm_token': 'token', 'platform': 'ANDROID'},
          ),
        ).thenAnswer(
          (_) async => const Success(SupabaseResponse(statusCode: 200)),
        );

        final result = await dataSource.registerDevice('token');

        expect(result, const Success<void, SupabaseFailure>(null));
        verify(
          () => mockSupabaseService.invokeFunction<dynamic>(
            functionName: 'register-device',
            body: {'fcm_token': 'token', 'platform': 'ANDROID'},
          ),
        ).called(1);
      });

      test('sends IOS as platform on iOS', () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        when(
          () => mockSupabaseService.invokeFunction<dynamic>(
            functionName: 'register-device',
            body: {'fcm_token': 'token', 'platform': 'IOS'},
          ),
        ).thenAnswer(
          (_) async => const Success(SupabaseResponse(statusCode: 200)),
        );

        await dataSource.registerDevice('token');

        verify(
          () => mockSupabaseService.invokeFunction<dynamic>(
            functionName: 'register-device',
            body: {'fcm_token': 'token', 'platform': 'IOS'},
          ),
        ).called(1);
      });

      test('fails without calling the backend on an unsupported platform', () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.macOS;

        final result = await dataSource.registerDevice('token');

        expect(result, isA<Failure<void, SupabaseFailure>>());
        verifyNever(
          () => mockSupabaseService.invokeFunction<dynamic>(
            functionName: any(named: 'functionName'),
            body: any(named: 'body'),
          ),
        );
      });

      test('propagates SupabaseFailure', () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        const failure = FunctionSupabaseFailure(message: 'error', code: '500');
        when(
          () => mockSupabaseService.invokeFunction<dynamic>(
            functionName: 'register-device',
            body: {'fcm_token': 'token', 'platform': 'ANDROID'},
          ),
        ).thenAnswer((_) async => const Failure(failure));

        final result = await dataSource.registerDevice('token');

        expect(result, const Failure<void, SupabaseFailure>(failure));
      });
    });

    group('unregisterDevice', () {
      test('invokes unregister-device with fcm_token in body', () async {
        when(
          () => mockSupabaseService.invokeFunction<dynamic>(
            functionName: 'unregister-device',
            body: {'fcm_token': 'token'},
          ),
        ).thenAnswer(
          (_) async => const Success(SupabaseResponse(statusCode: 204)),
        );

        final result = await dataSource.unregisterDevice('token');

        expect(result, const Success<void, SupabaseFailure>(null));
        verify(
          () => mockSupabaseService.invokeFunction<dynamic>(
            functionName: 'unregister-device',
            body: {'fcm_token': 'token'},
          ),
        ).called(1);
      });

      test('propagates SupabaseFailure', () async {
        const failure = FunctionSupabaseFailure(message: 'error', code: '500');
        when(
          () => mockSupabaseService.invokeFunction<dynamic>(
            functionName: 'unregister-device',
            body: {'fcm_token': 'token'},
          ),
        ).thenAnswer((_) async => const Failure(failure));

        final result = await dataSource.unregisterDevice('token');

        expect(result, const Failure<void, SupabaseFailure>(failure));
      });
    });

    test('getDeviceToken returns token from FirebaseMessaging', () async {
      when(() => mockMessaging.getToken()).thenAnswer((_) async => 'fcm-123');

      final token = await dataSource.getDeviceToken();

      expect(token, 'fcm-123');
      verify(() => mockMessaging.getToken()).called(1);
    });

    test('getDeviceToken rethrows when FirebaseMessaging throws', () async {
      when(
        () => mockMessaging.getToken(),
      ).thenThrow(Exception('APNs token not set'));

      await expectLater(dataSource.getDeviceToken(), throwsException);
    });

    test(
      'requestPermissions requests permission and keeps the system push hidden in foreground',
      () async {
        when(
          () => mockMessaging.requestPermission(
            alert: true,
            badge: true,
            sound: true,
          ),
        ).thenAnswer((_) async => FakeNotificationSettings());
        when(
          () => mockMessaging.setForegroundNotificationPresentationOptions(
            alert: false,
            badge: false,
            sound: false,
          ),
        ).thenAnswer((_) async {});

        await dataSource.requestPermissions();

        verify(
          () => mockMessaging.requestPermission(
            alert: true,
            badge: true,
            sound: true,
          ),
        ).called(1);
        verify(
          () => mockMessaging.setForegroundNotificationPresentationOptions(
            alert: false,
            badge: false,
            sound: false,
          ),
        ).called(1);
      },
    );

    test(
      'getInitialNotificationData returns data when initial message is non-empty',
      () async {
        when(() => mockMessaging.getInitialMessage()).thenAnswer(
          (_) async => const RemoteMessage(data: {'meeting_id': 'm-1'}),
        );

        final data = await dataSource.getInitialNotificationData();

        expect(data, {'meeting_id': 'm-1'});
      },
    );

    test(
      'getInitialNotificationData returns null when initial message is null or empty',
      () async {
        when(
          () => mockMessaging.getInitialMessage(),
        ).thenAnswer((_) async => null);
        expect(await dataSource.getInitialNotificationData(), isNull);

        when(
          () => mockMessaging.getInitialMessage(),
        ).thenAnswer((_) async => const RemoteMessage());
        expect(await dataSource.getInitialNotificationData(), isNull);
      },
    );

    test(
      'onNotificationOpened and onForegroundMessage map message data',
      () async {
        final openedFuture = dataSource.onNotificationOpened.first;
        final foregroundFuture = dataSource.onForegroundMessage.first;

        openedController.add(const RemoteMessage(data: {'group_id': 'g-1'}));
        foregroundController.add(
          const RemoteMessage(data: {'notification_id': 'n-1'}),
        );

        expect(await openedFuture, {'group_id': 'g-1'});
        expect(await foregroundFuture, {'notification_id': 'n-1'});
      },
    );
  });
}
