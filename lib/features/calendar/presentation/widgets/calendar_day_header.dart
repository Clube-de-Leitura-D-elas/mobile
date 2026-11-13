import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/calendar/presentation/widgets/calendar_labels.dart';

/// Cabeçalho da lista quando um dia está selecionado, com o botão de limpar.
class CalendarDayHeader extends StatelessWidget {
  final DateTime day;
  final VoidCallback onClear;

  const CalendarDayHeader({
    super.key,
    required this.day,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;

    return Row(
      children: [
        Expanded(
          child: Semantics(
            header: true,
            liveRegion: true,
            child: Text(
              calendarSelectedDayTitle(l10n, day),
              style: context.typography.bodyDefaultEmphasis.copyWith(
                color: colors.textDefault,
              ),
            ),
          ),
        ),
        IconButton(
          tooltip: l10n.calendarClearSelectedDay,
          onPressed: onClear,
          color: colors.textMuted,
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }
}
