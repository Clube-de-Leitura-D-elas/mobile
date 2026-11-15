import 'package:equatable/equatable.dart';

/// Mês exibido no calendário e a grade de 6 semanas (domingo a sábado) que o
/// representa.
class CalendarMonth extends Equatable {
  static const int visibleDayCount = 42;

  final int year;
  final int month;

  const CalendarMonth(this.year, this.month);

  factory CalendarMonth.of(DateTime date) {
    final normalized = DateTime(date.year, date.month);
    return CalendarMonth(normalized.year, normalized.month);
  }

  CalendarMonth get previous => CalendarMonth.of(DateTime(year, month - 1));

  CalendarMonth get next => CalendarMonth.of(DateTime(year, month + 1));

  DateTime get firstDay => DateTime(year, month);

  /// Domingo em que a grade começa (o próprio dia 1 quando ele é domingo).
  DateTime get firstVisibleDay =>
      DateTime(year, month, 1 - firstDay.weekday % DateTime.daysPerWeek);

  DateTime get lastVisibleDay => visibleDays.last;

  /// Os 42 dias da grade, cada um à meia-noite local.
  List<DateTime> get visibleDays {
    final first = firstVisibleDay;
    return List.generate(
      visibleDayCount,
      (index) => DateTime(first.year, first.month, first.day + index),
    );
  }

  bool contains(DateTime day) => day.year == year && day.month == month;

  @override
  List<Object?> get props => [year, month];
}
