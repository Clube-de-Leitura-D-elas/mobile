import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/notifications/domain/entities/notification_failure.dart';
import 'package:mobile/features/notifications/domain/repository/notification_repository.dart';
import 'package:mobile/features/notifications/domain/usecases/sync_fcm_token_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockNotificationRepository extends Mock
    implements NotificationRepository {}

void main() {
  late SyncFcmTokenUseCase useCase;
  late MockNotificationRepository mockRepository;

  setUp(() {
    mockRepository = MockNotificationRepository();
    useCase = SyncFcmTokenUseCase(repository: mockRepository);
  });

  test('delegates token synchronization to repository', () async {
    when(
      () => mockRepository.syncDeviceToken(),
    ).thenAnswer((_) async => const Success(null));

    final result = await useCase.execute();

    expect(result, const Success<void, NotificationFailure>(null));
    verify(() => mockRepository.syncDeviceToken()).called(1);
  });

  test('propagates failure when repository sync fails', () async {
    when(
      () => mockRepository.syncDeviceToken(),
    ).thenAnswer((_) async => const Failure(FcmTokenSyncFailure()));

    final result = await useCase.execute();

    expect(
      result,
      const Failure<void, NotificationFailure>(FcmTokenSyncFailure()),
    );
    verify(() => mockRepository.syncDeviceToken()).called(1);
  });
}
