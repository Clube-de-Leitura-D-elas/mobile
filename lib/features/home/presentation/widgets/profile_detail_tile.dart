import 'package:flutter/material.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';

/// Reusable profile detail tile item displayed in HomeScreen.
class ProfileDetailTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const ProfileDetailTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: colors.bgSubtle,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: colors.borderDefault),
        ),
        child: Row(
          children: [
            Icon(icon, color: colors.actionPrimary, size: 24),
            const Gap12(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: text.caption.copyWith(color: colors.textMuted),
                  ),
                  const Gap2(),
                  Text(
                    value.isNotEmpty ? value : l10n.notProvided,
                    style: text.bodyDefaultEmphasis.copyWith(color: colors.textDefault),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
