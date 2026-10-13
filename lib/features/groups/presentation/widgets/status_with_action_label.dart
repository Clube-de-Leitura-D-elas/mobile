import 'package:flutter/material.dart';
import 'package:mobile/design_system/design_system.dart';

class StatusWithActionLabel extends StatelessWidget {
  final String statusLabel;
  final IconData statusIcon;
  final Color statusColor;
  final Widget action;

  const StatusWithActionLabel({
    super.key,
    required this.statusLabel,
    required this.statusIcon,
    required this.statusColor,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    final typography = context.typography;
    final spacing = context.spacing;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(statusIcon, size: 16, color: statusColor),
            SizedBox(width: spacing.s4),
            Flexible(
              child: Text(
                statusLabel,
                style: typography.bodySmallEmphasis.copyWith(
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: spacing.s8),
        action,
      ],
    );
  }
}
