import 'package:flutter/material.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';

class MeetingTasksConcludeFooter extends StatelessWidget {
  const MeetingTasksConcludeFooter({
    super.key,
    required this.enabled,
    required this.onPressed,
  });

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          spacing.s16,
          spacing.s8,
          spacing.s16,
          spacing.s16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!enabled) ...[
              Text(
                context.l10n.meetingTasksConcludeHint,
                textAlign: TextAlign.center,
                style: context.typography.caption.copyWith(
                  color: context.colors.textMuted,
                ),
              ),
              SizedBox(height: spacing.s8),
            ],
            AppButton.primary(
              label: context.l10n.meetingTasksConcludeAction,
              onPressed: enabled ? onPressed : null,
            ),
          ],
        ),
      ),
    );
  }
}
