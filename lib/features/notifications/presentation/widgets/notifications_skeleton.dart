import 'package:flutter/material.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:shimmer/shimmer.dart';

class NotificationsSkeleton extends StatelessWidget {
  const NotificationsSkeleton({super.key});

  static const int rowCount = 6;
  static const double _rowHeight = 88;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    return Semantics(
      label: context.l10n.notificationsLoading,
      child: ExcludeSemantics(
        child: Shimmer.fromColors(
          baseColor: colors.surfaceSunken,
          highlightColor: colors.bgSubtle,
          child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.all(spacing.s16),
            itemCount: rowCount,
            separatorBuilder: (_, _) => SizedBox(height: spacing.s12),
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
