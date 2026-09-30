import 'package:flutter/material.dart';
import 'package:mobile/design_system/design_system.dart';

/// Linha de dado do encontro (ícone + texto). Diferente de `AppGroupInfoRow`,
/// o texto quebra em várias linhas em vez de ser cortado, para caber endereços
/// longos sem esconder informação.
class MeetingInfoRow extends StatelessWidget {
  const MeetingInfoRow({super.key, required this.icon, required this.label});

  final AppIconAsset icon;
  final String label;

  static const double _iconSize = 20;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppIcon(icon: icon, size: _iconSize, color: colors.textMuted),
        SizedBox(width: spacing.s8),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: spacing.s2),
            child: Text(
              label,
              style: context.typography.bodySmall.copyWith(
                color: colors.textMuted,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
