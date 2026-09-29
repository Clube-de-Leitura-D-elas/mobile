import 'package:flutter/material.dart';
import 'package:mobile/design_system/design_system.dart';

class GroupMetadata extends StatelessWidget {
  const GroupMetadata({
    super.key,
    required this.icon,
    required this.label,
    required this.maxWidth,
  });

  final AppIconAsset icon;
  final String label;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppIcon(icon: icon, size: spacing.s16, color: colors.textMuted),
          SizedBox(width: spacing.s4),
          Flexible(
            child: Text(
              label,
              style: context.text.bodySmall.copyWith(color: colors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}
