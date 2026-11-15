import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:shimmer/shimmer.dart';

class GroupSearchSkeleton extends StatelessWidget {
  const GroupSearchSkeleton({super.key});

  static const int rowCount = 4;
  static const double _rowHeight = 120;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    return Semantics(
      label: context.l10n.groupSearchLoading,
      child: ExcludeSemantics(
        child: Shimmer.fromColors(
          baseColor: colors.surfaceSunken,
          highlightColor: colors.bgSubtle,
          child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.all(spacing.s16),
            itemCount: rowCount,
            separatorBuilder: (_, _) => SizedBox(height: spacing.s16),
            itemBuilder: (_, _) => Container(
              height: _rowHeight,
              decoration: BoxDecoration(
                color: colors.surfaceSunken,
                borderRadius: BorderRadius.circular(AppCard.borderRadius),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
