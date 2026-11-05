import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/supabase/supabase_failure.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/notifications/data/datasources/notifications_remote_data_source.dart';
import 'package:mobile/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:mobile/features/notifications/domain/entities/notification_failure.dart';
import 'package:mocktail/mocktail.dart';

class MockNotificationsRemoteDataSource extends Mock
    implements NotificationsRemoteDataSource {}

class FakeNotificationSettings extends Fake implements NotificationSettings {}

void main() {
  late MockNotificationsRemoteDataSource mockDataSource;
  late NotificationsRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockNotificationsRemoteDataSource();
    repository = NotificationsRepositoryImpl(remoteDataSource: mockDataSource);
  });

  group('syncDeviceToken', () {
    test('requests permission, gets token and saves to backend on success', () async {
      when(() => mockDataSource.requestPermissions())
          .thenAnswer((_) async => FakeNotificationSettings());
      when(() => mockDataSource.getDeviceToken())
          .thenAnswer((_) async => 'fake_fcm_token_123');
      when(() => mockDataSource.saveTokenToBackend('fake_fcm_token_123'))
          .thenAnswer((_) async => const Success<void, SupabaseFailure>(null));

      final result = await repository.syncDeviceToken();

      expect(result, isA<Success<void, NotificationFailure>>());
      verify(() => mockDataSource.requestPermissions()).called(1);
      verify(() => mockDataSource.getDeviceToken()).called(1);
      verify(() => mockDataSource.saveTokenToBackend('fake_fcm_token_123')).called(1);
    });

    test('returns Success without saving if token is null or empty', () async {
      when(() => mockDataSource.requestPermissions())
          .thenAnswer((_) async => FakeNotificationSettings());
      when(() => mockDataSource.getDeviceToken()).thenAnswer((_) async => null);

      final result = await repository.syncDeviceToken();

      expect(result, isA<Success<void, NotificationFailure>>());
      verify(() => mockDataSource.requestPermissions()).called(1);
      verify(() => mockDataSource.getDeviceToken()).called(1);
      verifyNever(() => mockDataSource.saveTokenToBackend(any()));
    });

    test('returns Failure when saving to backend fails', () async {
      when(() => mockDataSource.requestPermissions())
          .thenAnswer((_) async => FakeNotificationSettings());
      when(() => mockDataSource.getDeviceToken())
          .thenAnswer((_) async => 'fake_fcm_token_123');
      when(() => mockDataSource.saveTokenToBackend('fake_fcm_token_123'))
          .thenAnswer((_) async => const Failure<void, SupabaseFailure>(
                FunctionSupabaseFailure(message: 'Backend error'),
              ));

      final result = await repository.syncDeviceToken();

      expect(result, isA<Failure<void, NotificationFailure>>());
      final unwrapped = (result as Failure<void, NotificationFailure>).failure;
      expect(unwrapped.message, 'Backend error');
    });
  });

  group('clearDeviceToken', () {
    test('calls saveTokenToBackend with null and returns Success', () async {
      when(() => mockDataSource.saveTokenToBackend(null))
          .thenAnswer((_) async => const Success<void, SupabaseFailure>(null));

      final result = await repository.clearDeviceToken();

      expect(result, isA<Success<void, NotificationFailure>>());
      verify(() => mockDataSource.saveTokenToBackend(null)).called(1);
    });

    test('returns Failure when backend call fails', () async {
      when(() => mockDataSource.saveTokenToBackend(null))
          .thenAnswer((_) async => const Failure<void, SupabaseFailure>(
                FunctionSupabaseFailure(message: 'Failed to clear'),
              ));

      final result = await repository.clearDeviceToken();

      expect(result, isA<Failure<void, NotificationFailure>>());
      final unwrapped = (result as Failure<void, NotificationFailure>).failure;
      expect(unwrapped.message, 'Failed to clear');
    });
  });
}
