import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/notifications/domain/entities/notification_failure.dart';
import 'package:mobile/features/notifications/domain/entities/notifications_page_entity.dart';
import 'package:mobile/features/notifications/domain/repository/notification_repository.dart';
import 'package:mobile/features/notifications/presentation/cubit/notification_badge_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockNotificationRepository extends Mock
    implements NotificationRepository {}

void main() {
  late MockNotificationRepository repository;

  setUp(() {
    repository = MockNotificationRepository();
  });

  blocTest<NotificationBadgeCubit, int>(
    'emits the unread count of the first page request',
    setUp: () => when(() => repository.getNotifications(page: 1)).thenAnswer(
      (_) async => const Success(
        NotificationsPageEntity(items: [], total: 50, unreadCount: 7),
      ),
    ),
    build: () => NotificationBadgeCubit(repository: repository),
    act: (cubit) => cubit.refresh(),
    expect: () => [7],
  );

  blocTest<NotificationBadgeCubit, int>(
    'drops to zero when everything is read',
    setUp: () => when(() => repository.getNotifications(page: 1)).thenAnswer(
      (_) async => const Success(
        NotificationsPageEntity(items: [], total: 50, unreadCount: 0),
      ),
    ),
    seed: () => 3,
    build: () => NotificationBadgeCubit(repository: repository),
    act: (cubit) => cubit.refresh(),
    expect: () => [0],
  );

  blocTest<NotificationBadgeCubit, int>(
    'keeps the last count when the request fails',
    setUp: () => when(
      () => repository.getNotifications(page: 1),
    ).thenAnswer((_) async => const Failure(NotificationsLoadFailure())),
    seed: () => 3,
    build: () => NotificationBadgeCubit(repository: repository),
    act: (cubit) => cubit.refresh(),
    expect: () => <int>[],
    verify: (cubit) => expect(cubit.state, 3),
  );
}
