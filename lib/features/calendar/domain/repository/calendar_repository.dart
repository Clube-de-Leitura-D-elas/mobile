import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/calendar/domain/entities/calendar_failure.dart';
import 'package:mobile/features/calendar/domain/entities/calendar_meeting_entity.dart';

abstract class CalendarRepository {
  /// Encontros da cidade da usuária entre [from] e [to], dias inclusivos.
  Future<Result<List<CalendarMeetingEntity>, CalendarFailure>> getMeetings({
    required DateTime from,
    required DateTime to,
  });
}
