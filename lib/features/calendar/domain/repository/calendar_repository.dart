import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/calendar/domain/entities/calendar_failure.dart';
import 'package:mobile/features/calendar/domain/entities/calendar_meeting_entity.dart';
import 'package:mobile/features/cities/domain/entities/city_scope.dart';

abstract class CalendarRepository {
  /// Encontros entre [from] e [to], dias inclusivos, das cidades de [city];
  /// sem [city], da cidade da leitora.
  Future<Result<List<CalendarMeetingEntity>, CalendarFailure>> getMeetings({
    required DateTime from,
    required DateTime to,
    CityScope? city,
  });

  /// Pede para a leitora participar de [meetingId], encontro de um grupo do
  /// qual ela não é membro.
  Future<Result<void, CalendarFailure>> requestParticipation(String meetingId);
}
