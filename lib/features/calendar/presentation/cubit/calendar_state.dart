import 'package:equatable/equatable.dart';
import 'package:mobile/features/calendar/domain/entities/calendar_failure.dart';
import 'package:mobile/features/calendar/domain/entities/calendar_meeting_entity.dart';
import 'package:mobile/features/calendar/domain/entities/calendar_month.dart';

enum CalendarStatus { loading, loaded, error }

enum CalendarFilter { all, upcoming, past }

class CalendarState extends Equatable {
  final CalendarStatus status;
  final CalendarMonth month;
  final DateTime today;

  /// Todos os encontros da grade, inclusive os dias de meses vizinhos.
  final List<CalendarMeetingEntity> meetings;

  /// Encontros do [month], já separados em relação ao momento da carga.
  final List<CalendarMeetingEntity> upcoming;
  final List<CalendarMeetingEntity> past;

  final CalendarFilter filter;
  final DateTime? selectedDay;

  /// Por que o mês não carregou, quando [status] é `error`.
  final CalendarFailure? failure;

  const CalendarState({
    required this.month,
    required this.today,
    this.status = CalendarStatus.loading,
    this.meetings = const [],
    this.upcoming = const [],
    this.past = const [],
    this.filter = CalendarFilter.all,
    this.selectedDay,
    this.failure,
  });

  Map<DateTime, int> get meetingCountByDay {
    final counts = <DateTime, int>{};
    for (final meeting in meetings) {
      counts.update(meeting.localDate, (count) => count + 1, ifAbsent: () => 1);
    }
    return counts;
  }

  /// O que a lista mostra: o dia selecionado tem prioridade sobre o filtro.
  List<CalendarMeetingEntity> get visibleMeetings {
    final day = selectedDay;
    if (day != null) {
      return [
        for (final meeting in meetings)
          if (meeting.localDate == day) meeting,
      ];
    }
    return switch (filter) {
      CalendarFilter.all => [...past, ...upcoming],
      CalendarFilter.upcoming => upcoming,
      CalendarFilter.past => past,
    };
  }

  CalendarState copyWith({
    CalendarFilter? filter,
    DateTime? selectedDay,
    bool clearSelectedDay = false,
  }) {
    return CalendarState(
      status: status,
      month: month,
      today: today,
      meetings: meetings,
      upcoming: upcoming,
      past: past,
      filter: filter ?? this.filter,
      selectedDay: clearSelectedDay ? null : selectedDay ?? this.selectedDay,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [
    status,
    month,
    today,
    meetings,
    upcoming,
    past,
    filter,
    selectedDay,
    failure,
  ];
}
