import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/notifications/domain/entities/notification_entity.dart';
import 'package:mobile/features/notifications/domain/entities/notification_type.dart';
import 'package:mobile/features/notifications/domain/entities/notification_failure.dart';
import 'package:mobile/features/notifications/domain/entities/notifications_page_entity.dart';
import 'package:mobile/features/notifications/domain/repository/notification_repository.dart';
import 'package:mobile/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:mobile/features/notifications/presentation/cubit/notifications_state.dart';
import 'package:mocktail/mocktail.dart';

class MockNotificationRepository extends Mock
    implements NotificationRepository {}

NotificationEntity _notification(String id, {bool isRead = false}) {
  return NotificationEntity(
    id: id,
    title: 'Título $id',
    message: 'Mensagem $id',
    type: NotificationType.meetingReminder,
    date: DateTime.utc(2026, 11, 5),
    isRead: isRead,
  );
}

void main() {
  late MockNotificationRepository repository;

  final n1 = _notification('n1');
  final n2 = _notification('n2');
  final n3 = _notification('n3');

  final loadedWithMore = NotificationsState(
    status: NotificationsStatus.loaded,
    items: [n1, n2],
    total: 45,
    page: 1,
  );

  void stubPage(int page, List<NotificationEntity> items, {int total = 45}) {
    when(() => repository.getNotifications(page: page)).thenAnswer(
      (_) async => Success(
        NotificationsPageEntity(items: items, total: total, unreadCount: 0),
      ),
    );
  }

  void stubPageFailure(int page) {
    when(
      () => repository.getNotifications(page: page),
    ).thenAnswer((_) async => const Failure(NotificationsLoadFailure()));
  }

  NotificationsCubit buildCubit() => NotificationsCubit(repository: repository);

  setUp(() {
    repository = MockNotificationRepository();
  });

  group('load', () {
    blocTest<NotificationsCubit, NotificationsState>(
      'emits the first page',
      setUp: () => stubPage(1, [n1, n2]),
      build: buildCubit,
      act: (cubit) => cubit.load(),
      expect: () => [
        const NotificationsState(),
        NotificationsState(
          status: NotificationsStatus.loaded,
          items: [n1, n2],
          total: 45,
          page: 1,
        ),
      ],
    );

    blocTest<NotificationsCubit, NotificationsState>(
      'emits an empty loaded state when there are no notifications',
      setUp: () => stubPage(1, [], total: 0),
      build: buildCubit,
      act: (cubit) => cubit.load(),
      expect: () => [
        const NotificationsState(),
        const NotificationsState(status: NotificationsStatus.loaded, page: 1),
      ],
      verify: (cubit) => expect(cubit.state.hasMore, isFalse),
    );

    blocTest<NotificationsCubit, NotificationsState>(
      'emits error when the repository fails',
      setUp: () => stubPageFailure(1),
      build: buildCubit,
      act: (cubit) => cubit.load(),
      expect: () => [
        const NotificationsState(),
        const NotificationsState(
          status: NotificationsStatus.error,
          failure: NotificationsLoadFailure(),
        ),
      ],
    );

    blocTest<NotificationsCubit, NotificationsState>(
      'recovers from an error on retry',
      setUp: () => stubPage(1, [n1], total: 1),
      seed: () => const NotificationsState(status: NotificationsStatus.error),
      build: buildCubit,
      act: (cubit) => cubit.load(),
      skip: 1,
      expect: () => [
        NotificationsState(
          status: NotificationsStatus.loaded,
          items: [n1],
          total: 1,
          page: 1,
        ),
      ],
    );
  });

  group('loadMore', () {
    blocTest<NotificationsCubit, NotificationsState>(
      'appends the next page',
      setUp: () => stubPage(2, [n3]),
      seed: () => loadedWithMore,
      build: buildCubit,
      act: (cubit) => cubit.loadMore(),
      expect: () => [
        loadedWithMore.copyWith(isLoadingMore: true),
        loadedWithMore.copyWith(items: [n1, n2, n3], page: 2),
      ],
    );

    blocTest<NotificationsCubit, NotificationsState>(
      'skips an item that shifted from the previous page',
      setUp: () => stubPage(2, [n2, n3]),
      seed: () => loadedWithMore,
      build: buildCubit,
      act: (cubit) => cubit.loadMore(),
      skip: 1,
      expect: () => [
        loadedWithMore.copyWith(items: [n1, n2, n3], page: 2),
      ],
    );

    blocTest<NotificationsCubit, NotificationsState>(
      'does nothing when every page is loaded',
      seed: () => NotificationsState(
        status: NotificationsStatus.loaded,
        items: [n1, n2],
        total: 2,
        page: 1,
      ),
      build: buildCubit,
      act: (cubit) => cubit.loadMore(),
      expect: () => <NotificationsState>[],
      verify: (_) => verifyNever(
        () => repository.getNotifications(page: any(named: 'page')),
      ),
    );

    blocTest<NotificationsCubit, NotificationsState>(
      'does not request the page twice while one is loading',
      seed: () => loadedWithMore.copyWith(isLoadingMore: true),
      build: buildCubit,
      act: (cubit) => cubit.loadMore(),
      expect: () => <NotificationsState>[],
      verify: (_) => verifyNever(
        () => repository.getNotifications(page: any(named: 'page')),
      ),
    );

    blocTest<NotificationsCubit, NotificationsState>(
      'clears the previous failure when retrying',
      setUp: () => stubPage(2, [n3]),
      seed: () => loadedWithMore.copyWith(loadMoreFailed: true),
      build: buildCubit,
      act: (cubit) => cubit.loadMore(),
      expect: () => [
        loadedWithMore.copyWith(isLoadingMore: true),
        loadedWithMore.copyWith(items: [n1, n2, n3], page: 2),
      ],
    );

    blocTest<NotificationsCubit, NotificationsState>(
      'keeps the loaded items and flags the failure',
      setUp: () => stubPageFailure(2),
      seed: () => loadedWithMore,
      build: buildCubit,
      act: (cubit) => cubit.loadMore(),
      expect: () => [
        loadedWithMore.copyWith(isLoadingMore: true),
        loadedWithMore.copyWith(loadMoreFailed: true),
      ],
    );
  });

  group('markAsRead', () {
    blocTest<NotificationsCubit, NotificationsState>(
      'marks the item before the backend answers and keeps it on success',
      setUp: () => when(
        () => repository.markAsRead('n1'),
      ).thenAnswer((_) async => const Success(null)),
      seed: () => loadedWithMore,
      build: buildCubit,
      act: (cubit) => cubit.markAsRead(n1),
      expect: () => [
        loadedWithMore.copyWith(items: [n1.copyWith(isRead: true), n2]),
      ],
      verify: (_) => verify(() => repository.markAsRead('n1')).called(1),
    );

    blocTest<NotificationsCubit, NotificationsState>(
      'rolls the item back when the backend refuses',
      setUp: () => when(
        () => repository.markAsRead('n1'),
      ).thenAnswer((_) async => const Failure(NotificationMarkReadFailure())),
      seed: () => loadedWithMore,
      build: buildCubit,
      act: (cubit) => cubit.markAsRead(n1),
      expect: () => [
        loadedWithMore.copyWith(items: [n1.copyWith(isRead: true), n2]),
        loadedWithMore,
      ],
    );

    blocTest<NotificationsCubit, NotificationsState>(
      'does not call the backend for an already read notification',
      seed: () => loadedWithMore,
      build: buildCubit,
      act: (cubit) => cubit.markAsRead(_notification('n1', isRead: true)),
      expect: () => <NotificationsState>[],
      verify: (_) => verifyNever(() => repository.markAsRead(any())),
    );
  });

  group('NotificationsState.hasMore', () {
    test('compares the fetched pages with the total', () {
      const pageSize = NotificationRepository.pageSize;

      expect(
        const NotificationsState(page: 1, total: pageSize + 1).hasMore,
        isTrue,
      );
      expect(
        const NotificationsState(page: 1, total: pageSize).hasMore,
        isFalse,
      );
    });
  });
}
