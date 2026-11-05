import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/supabase/supabase_failure.dart';
import 'package:mobile/core/supabase/supabase_response.dart';
import 'package:mobile/core/supabase/supabase_service.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/notifications/data/models/notifications_page_model.dart';
import 'package:mobile/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:mobile/features/notifications/domain/entities/notification_failure.dart';
import 'package:mobile/features/notifications/domain/entities/notifications_page_entity.dart';
import 'package:mobile/features/notifications/domain/repository/notification_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockSupabaseService extends Mock implements SupabaseService {}

void main() {
  late MockSupabaseService service;
  late NotificationRepositoryImpl repository;

  setUp(() {
    service = MockSupabaseService();
    repository = NotificationRepositoryImpl(supabaseService: service);
  });

  group('getNotifications', () {
    void stubList(
      Result<SupabaseResponse<NotificationsPageModel>, SupabaseFailure> result,
    ) {
      when(
        () => service.invokeFunction<NotificationsPageModel>(
          functionName: any(named: 'functionName'),
          queryParameters: any(named: 'queryParameters'),
          decoder: any(named: 'decoder'),
        ),
      ).thenAnswer((_) async => result);
    }

    test('asks for the page in the query string and decodes it', () async {
      stubList(
        const Success(
          SupabaseResponse(
            data: NotificationsPageModel(
              notifications: [],
              total: 45,
              unreadCount: 3,
            ),
          ),
        ),
      );

      final result = await repository.getNotifications(page: 2);

      expect(result.unwrap().total, 45);
      expect(result.unwrap().unreadCount, 3);

      final call = verify(
        () => service.invokeFunction<NotificationsPageModel>(
          functionName: 'get-my-notifications',
          queryParameters: {
            'page': '2',
            'pageSize': '${NotificationRepository.pageSize}',
          },
          decoder: captureAny(named: 'decoder'),
        ),
      )..called(1);

      final decoder =
          call.captured.single as NotificationsPageModel Function(dynamic);
      final decoded = decoder({
        'notifications': <dynamic>[],
        'total': 1,
        'unread_count': 1,
      });
      expect(decoded.total, 1);
    });

    test('maps a backend failure to NotificationsLoadFailure', () async {
      stubList(
        const Failure(FunctionSupabaseFailure(message: 'boom', code: '500')),
      );

      final result = await repository.getNotifications(page: 1);

      expect(
        result,
        const Failure<NotificationsPageEntity, NotificationFailure>(
          NotificationsLoadFailure(),
        ),
      );
    });

    test('treats an empty response as NotificationsLoadFailure', () async {
      stubList(const Success(SupabaseResponse()));

      final result = await repository.getNotifications(page: 1);

      expect(
        result,
        const Failure<NotificationsPageEntity, NotificationFailure>(
          NotificationsLoadFailure(),
        ),
      );
    });
  });

  group('markAsRead', () {
    void stubMark(Result<SupabaseResponse<void>, SupabaseFailure> result) {
      when(
        () => service.invokeFunction<void>(
          functionName: any(named: 'functionName'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => result);
    }

    test('sends notification_id to mark-notification-read', () async {
      stubMark(const Success(SupabaseResponse()));

      final result = await repository.markAsRead('n1');

      expect(result, const Success<void, NotificationFailure>(null));
      verify(
        () => service.invokeFunction<void>(
          functionName: 'mark-notification-read',
          body: {'notification_id': 'n1'},
        ),
      ).called(1);
    });

    test('maps a backend failure to NotificationMarkReadFailure', () async {
      stubMark(
        const Failure(FunctionSupabaseFailure(message: 'boom', code: '404')),
      );

      final result = await repository.markAsRead('n1');

      expect(
        result,
        const Failure<void, NotificationFailure>(NotificationMarkReadFailure()),
      );
    });
  });
}
