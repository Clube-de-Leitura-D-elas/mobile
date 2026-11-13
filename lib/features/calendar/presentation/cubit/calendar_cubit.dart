import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/core/tools/sao_paulo_time.dart';
import 'package:mobile/features/calendar/domain/entities/calendar_month.dart';
import 'package:mobile/features/calendar/domain/repository/calendar_repository.dart';
import 'package:mobile/features/calendar/presentation/cubit/calendar_state.dart';

class CalendarCubit extends Cubit<CalendarState> {
  final CalendarRepository repository;
  final DateTime Function() _now;

  /// Só a resposta da requisição mais recente é aplicada.
  int _latestRequest = 0;

  CalendarCubit({
    required this.repository,
    DateTime Function() now = DateTime.now,
  }) : _now = now,
       super(
         CalendarState(
           month: CalendarMonth.of(toSaoPaulo(now())),
           today: saoPauloDayOf(now()),
         ),
       );

  Future<void> load() => _load(state.month);

  Future<void> showPreviousMonth() => _load(state.month.previous);

  Future<void> showNextMonth() => _load(state.month.next);

  void selectFilter(CalendarFilter filter) {
    emit(state.copyWith(filter: filter, clearSelectedDay: true));
  }

  /// Tocar de novo no dia selecionado limpa a seleção. Dias de meses
  /// vizinhos não são selecionáveis.
  void selectDay(DateTime day) {
    final normalized = DateTime(day.year, day.month, day.day);
    if (!state.month.contains(normalized)) return;
    if (state.selectedDay == normalized) {
      clearSelectedDay();
      return;
    }
    emit(state.copyWith(selectedDay: normalized));
  }

  void clearSelectedDay() {
    emit(state.copyWith(clearSelectedDay: true));
  }

  /// O dia selecionado sobrevive à recarga do mesmo mês (inclusive ao
  /// "tentar novamente") e a uma seleção feita durante o carregamento, com
  /// sucesso ou erro; trocar de mês limpa.
  Future<void> _load(CalendarMonth month) async {
    final request = ++_latestRequest;
    final now = _now();
    emit(
      CalendarState(
        month: month,
        today: saoPauloDayOf(now),
        filter: state.filter,
        selectedDay: month == state.month ? state.selectedDay : null,
      ),
    );

    final result = await repository.getMeetings(
      from: month.firstVisibleDay,
      to: month.lastVisibleDay,
    );
    if (isClosed || request != _latestRequest) return;

    switch (result) {
      case Failure(:final failure):
        emit(
          CalendarState(
            month: month,
            today: state.today,
            filter: state.filter,
            selectedDay: state.selectedDay,
            status: CalendarStatus.error,
            failure: failure,
          ),
        );
      case Success(:final data):
        final meetings = [...data]..sort((a, b) => a.date.compareTo(b.date));
        final ofMonth = meetings.where(
          (meeting) => month.contains(meeting.localDate),
        );
        emit(
          CalendarState(
            month: month,
            today: state.today,
            filter: state.filter,
            selectedDay: state.selectedDay,
            status: CalendarStatus.loaded,
            meetings: meetings,
            upcoming: [
              for (final meeting in ofMonth)
                if (meeting.isUpcomingAt(now)) meeting,
            ],
            past: [
              for (final meeting in ofMonth)
                if (!meeting.isUpcomingAt(now)) meeting,
            ],
          ),
        );
    }
  }
}
