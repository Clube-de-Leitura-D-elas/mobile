import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:shimmer/shimmer.dart';

class CalendarListSkeleton extends StatelessWidget {
  const CalendarListSkeleton({super.key});

  static const int rowCount = 3;
  static const double _rowHeight = 112;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    return Semantics(
      label: context.l10n.calendarLoading,
      child: ExcludeSemantics(
        child: Shimmer.fromColors(
          baseColor: colors.surfaceSunken,
          highlightColor: colors.bgSubtle,
          child: Column(
            children: [
              for (var index = 0; index < rowCount; index++)
                Padding(
                  padding: EdgeInsets.only(bottom: spacing.s12),
                  child: Container(
                    height: _rowHeight,
                    decoration: BoxDecoration(
                      color: colors.surfaceSunken,
                      borderRadius: BorderRadius.circular(AppCard.borderRadius),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
