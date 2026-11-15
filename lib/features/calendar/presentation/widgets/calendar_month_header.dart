import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/calendar/domain/entities/calendar_month.dart';
import 'package:mobile/features/calendar/presentation/widgets/calendar_labels.dart';

class CalendarMonthHeader extends StatelessWidget {
  final CalendarMonth month;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const CalendarMonthHeader({
    super.key,
    required this.month,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final l10n = context.l10n;

    return Row(
      children: [
        Expanded(
          child: Semantics(
            header: true,
            liveRegion: true,
            label: calendarMonthSemantic(l10n, month.firstDay),
            excludeSemantics: true,
            child: Text(
              calendarMonthTitle(l10n, month),
              style: typography.headingH2.copyWith(color: colors.textDefault),
            ),
          ),
        ),
        IconButton(
          tooltip: l10n.calendarPreviousMonth,
          onPressed: onPrevious,
          color: colors.textDefault,
          icon: const Icon(Icons.chevron_left),
        ),
        IconButton(
          tooltip: l10n.calendarNextMonth,
          onPressed: onNext,
          color: colors.textDefault,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}
