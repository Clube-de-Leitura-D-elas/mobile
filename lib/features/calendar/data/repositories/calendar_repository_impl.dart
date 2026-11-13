import 'package:flutter/foundation.dart';
import 'package:mobile/core/supabase/supabase_failure.dart';
import 'package:mobile/core/supabase/supabase_service.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/calendar/data/models/calendar_meeting_model.dart';
import 'package:mobile/features/calendar/domain/entities/calendar_failure.dart';
import 'package:mobile/features/calendar/domain/entities/calendar_meeting_entity.dart';
import 'package:mobile/features/calendar/domain/repository/calendar_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CalendarRepositoryImpl implements CalendarRepository {
  CalendarRepositoryImpl({required this.supabaseService});

  final SupabaseService supabaseService;

  @override
  Future<Result<List<CalendarMeetingEntity>, CalendarFailure>> getMeetings({
    required DateTime from,
    required DateTime to,
  }) async {
    final result = await supabaseService
        .invokeFunction<List<CalendarMeetingModel>>(
          functionName: 'get-city-calendar',
          method: HttpMethod.get,
          queryParameters: {'from': _civilDate(from), 'to': _civilDate(to)},
          decoder: (data) =>
              CalendarMeetingModel.listFromJson(data as Map<String, dynamic>),
        );

    switch (result) {
      case Failure(:final failure):
        return Failure(_failureFrom(failure));
      case Success(:final data):
        final models = data.data;
        if (models == null) return const Failure(CalendarLoadFailure());
        return Success([for (final model in models) model.toDomain()]);
    }
  }

  @override
  Future<Result<void, CalendarFailure>> requestParticipation(
    String meetingId,
  ) async {
    final result = await supabaseService.invokeFunction<void>(
      functionName: 'request-meeting-participation',
      body: {'meeting_id': meetingId},
    );

    return switch (result) {
      Failure(:final failure) => Failure(_participationFailureFrom(failure)),
      Success() => const Success(null),
    };
  }

  /// `YYYY-MM-DD` do dia civil; `toIso8601String` levaria hora e fuso.
  static String _civilDate(DateTime day) {
    final month = day.month.toString().padLeft(2, '0');
    final dayOfMonth = day.day.toString().padLeft(2, '0');
    return '${day.year}-$month-$dayOfMonth';
  }

  CalendarFailure _failureFrom(SupabaseFailure failure) {
    debugPrint('[CalendarFailure] ${failure.message} (${failure.code})');
    return switch (failure.kind) {
      SupabaseFailureKind.network => const CalendarNetworkFailure(),
      SupabaseFailureKind.unauthorized => const CalendarSessionExpiredFailure(),
      SupabaseFailureKind.forbidden => const CalendarForbiddenFailure(),
      _ => const CalendarLoadFailure(),
    };
  }

  /// O backend usa o mesmo status para casos diferentes; o texto em `error`
  /// (que chega no `message`) diz qual.
  CalendarFailure _participationFailureFrom(SupabaseFailure failure) {
    debugPrint('[CalendarFailure] ${failure.message} (${failure.code})');
    final message = failure.message;
    return switch (failure.kind) {
      SupabaseFailureKind.network => const CalendarNetworkFailure(),
      SupabaseFailureKind.unauthorized => const CalendarSessionExpiredFailure(),
      SupabaseFailureKind.forbidden
          when message.contains('meeting not available') =>
        const CalendarMeetingUnavailableFailure(),
      SupabaseFailureKind.forbidden when message.contains('inactive account') =>
        const CalendarForbiddenFailure(),
      SupabaseFailureKind.notFound when message.contains('meeting not found') =>
        const CalendarMeetingNotFoundFailure(),
      SupabaseFailureKind.conflict when message.contains('already requested') =>
        const CalendarGuestAlreadyRequestedFailure(),
      SupabaseFailureKind.conflict when message.contains('already a member') =>
        const CalendarGuestAlreadyMemberFailure(),
      SupabaseFailureKind.conflict when message.contains('recently rejected') =>
        const CalendarGuestRecentlyRejectedFailure(),
      SupabaseFailureKind.conflict when message.contains('meeting not open') =>
        const CalendarMeetingNotOpenFailure(),
      SupabaseFailureKind.conflict
          when message.contains('meeting has no reviewer') =>
        const CalendarMeetingNoReviewerFailure(),
      _ => const CalendarGuestRequestFailure(),
    };
  }
}
