import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/calendar/presentation/cubit/calendar_state.dart';

class CalendarFilterChips extends StatelessWidget {
  final CalendarFilter selected;
  final int upcomingCount;
  final ValueChanged<CalendarFilter> onSelected;

  const CalendarFilterChips({
    super.key,
    required this.selected,
    required this.upcomingCount,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.spacing;

    return Wrap(
      spacing: spacing.s8,
      children: [
        for (final filter in CalendarFilter.values)
          _FilterChip(
            label: switch (filter) {
              CalendarFilter.all => l10n.calendarFilterAll,
              CalendarFilter.upcoming => l10n.calendarFilterUpcoming(
                upcomingCount,
              ),
              CalendarFilter.past => l10n.calendarFilterPast,
            },
            isSelected: filter == selected,
            onTap: () => onSelected(filter),
          ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // O AppChip não expõe seleção; o MergeSemantics junta o `selected` ao nó
    // de botão dele.
    return MergeSemantics(
      child: Semantics(
        selected: isSelected,
        child: AppChip(
          label: label,
          variant: isSelected ? AppChipVariant.filled : AppChipVariant.outlined,
          onTap: onTap,
        ),
      ),
    );
  }
}
