import 'package:flutter/material.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';

class HomePendingTasksBanner extends StatelessWidget {
  final VoidCallback onPressed;

  const HomePendingTasksBanner({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final l10n = context.l10n;
    final borderRadius = BorderRadius.circular(AppCard.borderRadius);

    return Semantics(
      button: true,
      label: '${l10n.homePendingTasksMessage}, ${l10n.homePendingTasksAction}',
      excludeSemantics: true,
      child: Material(
        color: colors.surfaceBrandSoft,
        borderRadius: borderRadius,
        child: InkWell(
          onTap: onPressed,
          borderRadius: borderRadius,
          child: Ink(
            padding: EdgeInsets.all(spacing.s12),
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              border: Border.all(
                color: colors.borderBrand.withValues(alpha: 0.3),
              ),
            ),
            child: const _BannerContent(),
          ),
        ),
      ),
    );
  }
}

class _BannerContent extends StatelessWidget {
  const _BannerContent();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;

    return Row(
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
            context.l10n.homePendingTasksMessage,
            style: typography.bodySmallEmphasis.copyWith(
              color: colors.textDefault,
            ),
          ),
        ),
        SizedBox(width: spacing.s8),
        const _TasksChip(),
      ],
    );
  }
}

/// Indicação visual da ação; o toque é tratado pelo banner inteiro.
class _TasksChip extends StatelessWidget {
  const _TasksChip();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceDefault,
        borderRadius: BorderRadius.circular(999),
      ),
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
              context.l10n.homePendingTasksAction,
              style: typography.bodySmallEmphasis.copyWith(
                color: colors.textBrand,
              ),
            ),
            SizedBox(width: spacing.s4),
            Icon(Icons.chevron_right, size: 18, color: colors.textBrand),
          ],
        ),
      ),
    );
  }
}
