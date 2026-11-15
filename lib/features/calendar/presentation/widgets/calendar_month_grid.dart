import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/calendar/domain/entities/calendar_month.dart';

class CalendarMonthGrid extends StatelessWidget {
  final CalendarMonth month;
  final DateTime today;
  final DateTime? selectedDay;

  /// Quantidade de encontros por dia (à meia-noite local).
  final Map<DateTime, int> meetingCountByDay;
  final ValueChanged<DateTime> onDaySelected;

  const CalendarMonthGrid({
    super.key,
    required this.month,
    required this.today,
    required this.selectedDay,
    required this.meetingCountByDay,
    required this.onDaySelected,
  });

  static const List<String> _weekdays = [
    'sunday',
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final days = month.visibleDays;
    final weekdayStyle = context.typography.caption.copyWith(
      color: context.colors.textMuted,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            for (final weekday in _weekdays)
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    l10n.calendarWeekdayShort(weekday),
                    maxLines: 1,
                    style: weekdayStyle,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: context.spacing.s4),
        for (var week = 0; week < days.length; week += DateTime.daysPerWeek)
          Row(
            children: [
              for (final day in days.sublist(week, week + DateTime.daysPerWeek))
                Expanded(
                  child: CalendarDayCell(
                    day: day,
                    isInMonth: month.contains(day),
                    isToday: day == today,
                    isSelected: day == selectedDay,
                    meetingCount: meetingCountByDay[day] ?? 0,
                    onTap: () => onDaySelected(day),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class CalendarDayCell extends StatelessWidget {
  final DateTime day;
  final bool isInMonth;
  final bool isToday;
  final bool isSelected;
  final int meetingCount;
  final VoidCallback onTap;

  const CalendarDayCell({
    super.key,
    required this.day,
    required this.isInMonth,
    required this.isToday,
    required this.isSelected,
    required this.meetingCount,
    required this.onTap,
  });

  /// Alvo de toque mínimo; a largura vem da coluna da grade.
  static const double minHeight = 48;
  static const double _circleSize = 32;
  static const double _markerWidth = 16;
  static const double _markerHeight = 3;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final l10n = context.l10n;
    final hasMeeting = meetingCount > 0;

    final Color textColor;
    final Color? circleColor;
    if (isSelected) {
      textColor = colors.textOnBrand;
      circleColor = colors.actionPrimary;
    } else if (isToday && isInMonth) {
      textColor = colors.textBrand;
      circleColor = colors.surfaceBrandSoft;
    } else {
      textColor = isInMonth ? colors.textDefault : colors.textMuted;
      circleColor = null;
    }

    // Com fonte grande o número encolhe dentro do círculo em vez de estourar.
    final content = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: minHeight),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: _circleSize,
            height: _circleSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: circleColor,
              shape: BoxShape.circle,
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '${day.day}',
                maxLines: 1,
                style:
                    (isToday || isSelected
                            ? typography.bodySmallEmphasis
                            : typography.bodySmall)
                        .copyWith(color: textColor),
              ),
            ),
          ),
          SizedBox(height: context.spacing.s2),
          Container(
            key: hasMeeting ? ValueKey('calendar-marker-$day') : null,
            width: _markerWidth,
            height: _markerHeight,
            decoration: BoxDecoration(
              color: hasMeeting
                  ? (isInMonth ? colors.actionPrimary : colors.borderBrand)
                  : null,
              borderRadius: BorderRadius.circular(_markerHeight),
            ),
          ),
        ],
      ),
    );

    // Dia de mês vizinho não reage ao toque: fica fora da árvore semântica.
    if (!isInMonth) return ExcludeSemantics(child: content);

    return Semantics(
      button: true,
      selected: isSelected,
      label: l10n.calendarDaySemantic(day, meetingCount),
      value: isToday ? l10n.calendarToday : null,
      onTap: onTap,
      excludeSemantics: true,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: content,
      ),
    );
  }
}
