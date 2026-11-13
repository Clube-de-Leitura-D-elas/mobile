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

  /// Encontros com pedido de participação em andamento.
  final Set<String> requestingIds;

  /// Retorno do último pedido de participação, para um aviso único na tela;
  /// a tela limpa com `clearParticipationFeedback` depois de mostrar.
  final bool participationRequested;
  final CalendarFailure? participationFailure;

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
    this.requestingIds = const {},
    this.participationRequested = false,
    this.participationFailure,
  });

  bool get hasParticipationFeedback =>
      participationRequested || participationFailure != null;

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
    List<CalendarMeetingEntity>? meetings,
    List<CalendarMeetingEntity>? upcoming,
    List<CalendarMeetingEntity>? past,
    Set<String>? requestingIds,
    bool? participationRequested,
    CalendarFailure? participationFailure,
    bool clearParticipationFailure = false,
  }) {
    return CalendarState(
      status: status,
      month: month,
      today: today,
      meetings: meetings ?? this.meetings,
      upcoming: upcoming ?? this.upcoming,
      past: past ?? this.past,
      filter: filter ?? this.filter,
      selectedDay: clearSelectedDay ? null : selectedDay ?? this.selectedDay,
      failure: failure,
      requestingIds: requestingIds ?? this.requestingIds,
      participationRequested:
          participationRequested ?? this.participationRequested,
      participationFailure: clearParticipationFailure
          ? null
          : participationFailure ?? this.participationFailure,
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
    requestingIds,
    participationRequested,
    participationFailure,
  ];
}
