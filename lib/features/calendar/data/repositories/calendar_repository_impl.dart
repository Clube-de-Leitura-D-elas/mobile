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
}
