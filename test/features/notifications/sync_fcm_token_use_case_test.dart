import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/notifications/domain/entities/notification_failure.dart';
import 'package:mobile/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:mobile/features/notifications/domain/usecases/sync_fcm_token_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockNotificationsRepository extends Mock implements NotificationsRepository {}

void main() {
  late MockNotificationsRepository mockRepository;
  late SyncFcmTokenUseCase useCase;

  setUp(() {
    mockRepository = MockNotificationsRepository();
    useCase = SyncFcmTokenUseCase(repository: mockRepository);
  });

  test('should return Success when repository successfully syncs device token', () async {
    when(() => mockRepository.syncDeviceToken())
        .thenAnswer((_) async => const Success<void, NotificationFailure>(null));

    final result = await useCase.execute();

    expect(result, isA<Success<void, NotificationFailure>>());
    verify(() => mockRepository.syncDeviceToken()).called(1);
  });

  test('should return Failure when repository fails to sync device token', () async {
    const failure = NotificationFailure(message: 'Error syncing token');
    when(() => mockRepository.syncDeviceToken())
        .thenAnswer((_) async => const Failure<void, NotificationFailure>(failure));

    final result = await useCase.execute();

    expect(result, isA<Failure<void, NotificationFailure>>());
    final unwrapped = (result as Failure<void, NotificationFailure>).failure;
    expect(unwrapped.message, 'Error syncing token');
    verify(() => mockRepository.syncDeviceToken()).called(1);
  });
}
