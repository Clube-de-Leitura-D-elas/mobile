import 'package:flutter/material.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';

class GroupParticipantsErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const GroupParticipantsErrorView({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final l10n = context.l10n;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: spacing.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            liveRegion: true,
            child: Text(
              l10n.groupParticipantsLoadError,
              style: context.text.bodyDefault.copyWith(color: colors.textMuted),
            ),
          ),
          SizedBox(height: spacing.s12),
          AppButton.secondary(
            label: l10n.groupParticipantsRetryButton,
            size: AppButtonSize.sm,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}
