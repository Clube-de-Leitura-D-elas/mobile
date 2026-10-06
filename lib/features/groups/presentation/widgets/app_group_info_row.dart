import 'package:flutter/material.dart';
import 'package:mobile/design_system/design_system.dart';

class AppGroupInfoRow extends StatelessWidget {
  final AppIconAsset icon;
  final String label;

  const AppGroupInfoRow({super.key, required this.icon, required this.label});

  static const double _size = 16;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppIcon(icon: icon, size: _size, color: colors.textMuted),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            style: typography.bodySmall.copyWith(color: colors.textMuted),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
