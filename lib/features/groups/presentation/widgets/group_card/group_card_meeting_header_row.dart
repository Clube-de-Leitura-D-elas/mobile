import 'package:flutter/material.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';

class GroupCardMeetingHeaderRow extends StatelessWidget {
  final bool expanded;
  final VoidCallback? onToggleExpanded;

  const GroupCardMeetingHeaderRow({
    super.key,
    required this.expanded,
    required this.onToggleExpanded,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final l10n = context.l10n;

    return Semantics(
      button: true,
      expanded: expanded,
      label: l10n.groupNextMeetingLabel,
      child: InkWell(
        onTap: onToggleExpanded,
        borderRadius: BorderRadius.circular(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.groupNextMeetingLabel,
              style: typography.bodyLarge.copyWith(color: colors.textMuted),
            ),
            Icon(
              expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: colors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
