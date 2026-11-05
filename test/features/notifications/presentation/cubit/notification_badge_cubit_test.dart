import 'dart:async';

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

typedef PageResult = Result<NotificationsPageEntity, NotificationFailure>;

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

  group('overlapping refreshes', () {
    late List<Completer<PageResult>> calls;
    late NotificationBadgeCubit cubit;

    PageResult unread(int count) => Success(
      NotificationsPageEntity(items: const [], total: 50, unreadCount: count),
    );

    setUp(() {
      calls = [];
      when(() => repository.getNotifications(page: 1)).thenAnswer((_) {
        final call = Completer<PageResult>();
        calls.add(call);
        return call.future;
      });
      cubit = NotificationBadgeCubit(repository: repository);
      addTearDown(cubit.close);
    });

    test('ignores an older response that arrives last', () async {
      final older = cubit.refresh();
      final newer = cubit.refresh();

      calls[1].complete(unread(1));
      await newer;
      calls[0].complete(unread(5));
      await older;

      expect(cubit.state, 1);
    });

    test('applies responses that arrive in order', () async {
      final older = cubit.refresh();
      final newer = cubit.refresh();

      calls[0].complete(unread(5));
      await older;
      calls[1].complete(unread(1));
      await newer;

      expect(cubit.state, 1);
    });

    test('keeps an older success when the newer request fails', () async {
      final older = cubit.refresh();
      final newer = cubit.refresh();

      calls[1].complete(const Failure(NotificationsLoadFailure()));
      await newer;
      calls[0].complete(unread(5));
      await older;

      expect(cubit.state, 5);
    });
  });
}
