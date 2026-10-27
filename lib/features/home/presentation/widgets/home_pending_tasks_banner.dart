import 'package:flutter/material.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';

class HomePendingTasksBanner extends StatelessWidget {
  final VoidCallback onPressed;

  const HomePendingTasksBanner({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final l10n = context.l10n;

    return Container(
      padding: EdgeInsets.all(spacing.s12),
      decoration: BoxDecoration(
        color: colors.surfaceBrandSoft,
        borderRadius: BorderRadius.circular(AppCard.borderRadius),
        border: Border.all(color: colors.borderBrand.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          AppIcon(
            icon: AppIcons.tasks,
            size: 18,
            color: colors.textOnBrand,
            backgroundColor: colors.actionPrimary,
            padding: EdgeInsets.all(spacing.s8),
            borderRadius: BorderRadius.circular(999),
          ),
          SizedBox(width: spacing.s12),
          Expanded(
            child: Text(
              l10n.homePendingTasksMessage,
              style: typography.bodySmallEmphasis.copyWith(
                color: colors.textDefault,
              ),
            ),
          ),
          SizedBox(width: spacing.s8),
          _TasksButton(onPressed: onPressed),
        ],
      ),
    );
  }
}

class _TasksButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _TasksButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final label = context.l10n.homePendingTasksAction;
    final borderRadius = BorderRadius.circular(999);

    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: colors.surfaceDefault,
        borderRadius: borderRadius,
        child: InkWell(
          onTap: onPressed,
          borderRadius: borderRadius,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              spacing.s12,
              spacing.s4,
              spacing.s8,
              spacing.s4,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: typography.bodySmallEmphasis.copyWith(
                    color: colors.textBrand,
                  ),
                ),
                SizedBox(width: spacing.s4),
                Icon(Icons.chevron_right, size: 18, color: colors.textBrand),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
