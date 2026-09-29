import 'package:flutter/material.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';

class GroupActions extends StatelessWidget {
  const GroupActions({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.spacing;
    return LayoutBuilder(
      builder: (context, constraints) {
        final buttons = [
          AppButton.secondary(
            label: l10n.groupOpenWhatsAppButton,
            size: AppButtonSize.sm,
            onPressed: () {},
          ),
          AppButton.primary(
            label: l10n.groupRecommendBookButton,
            size: AppButtonSize.sm,
            onPressed: () {},
          ),
        ];

        if (constraints.maxWidth < 280) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buttons.first,
              SizedBox(height: spacing.s8),
              buttons.last,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: buttons.first),
            SizedBox(width: spacing.s8),
            Expanded(child: buttons.last),
          ],
        );
      },
    );
  }
}
