import 'package:mobile/core/supabase/supabase_service.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/notifications/data/models/notifications_page_model.dart';
import 'package:mobile/features/notifications/domain/entities/notification_failure.dart';
import 'package:mobile/features/notifications/domain/entities/notifications_page_entity.dart';
import 'package:mobile/features/notifications/domain/repository/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl({required this.supabaseService});

  final SupabaseService supabaseService;

  @override
  Future<Result<NotificationsPageEntity, NotificationFailure>>
  getNotifications({required int page}) async {
    final result = await supabaseService.invokeFunction<NotificationsPageModel>(
      functionName: 'get-my-notifications',
      // A function lê a paginação da query string, não do body.
      queryParameters: {
        'page': '$page',
        'pageSize': '${NotificationRepository.pageSize}',
      },
      decoder: (data) =>
          NotificationsPageModel.fromJson(data as Map<String, dynamic>),
    );

    switch (result) {
      case Failure():
        return const Failure(NotificationsLoadFailure());
      case Success(:final data):
        final model = data.data;
        if (model == null) return const Failure(NotificationsLoadFailure());
        return Success(model.toDomain());
    }
  }

  @override
  Future<Result<void, NotificationFailure>> markAsRead(
    String notificationId,
  ) async {
    final result = await supabaseService.invokeFunction<void>(
      functionName: 'mark-notification-read',
      body: {'notification_id': notificationId},
    );

    return switch (result) {
      Failure() => const Failure(NotificationMarkReadFailure()),
      Success() => const Success(null),
    };
  }
}
