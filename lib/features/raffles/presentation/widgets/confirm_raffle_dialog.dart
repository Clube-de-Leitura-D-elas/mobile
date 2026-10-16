import 'package:flutter/material.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';

class ConfirmRaffleDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const ConfirmRaffleDialog({super.key, required this.onConfirm});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) =>
          ConfirmRaffleDialog(onConfirm: () => Navigator.of(context).pop(true)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      backgroundColor: colors.bgDefault,
      child: Padding(
        padding: EdgeInsets.all(spacing.s24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    context
                        .l10n
                        .raffleConfirmDialogTitle, // "Confirmar sorteio"
                    style: typography.headingH3.copyWith(
                      color: colors.textDefault,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Gap16(),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(false),
                  child: Icon(Icons.close, color: colors.textDefault, size: 20),
                ),
              ],
            ),
            const Gap16(),
            Text(
              context
                  .l10n
                  .raffleConfirmDialogMessage, // "Você deseja mesmo confirmar o sorteio?"
              style: typography.bodyDefault.copyWith(color: colors.textMuted),
            ),
            const Gap24(),
            Row(
              children: [
                Expanded(
                  child: AppButton.secondary(
                    label: context.l10n.raffleConfirmDialogCancel, // "Cancelar"
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ),
                const Gap16(),
                Expanded(
                  child: AppButton.primary(
                    label: context
                        .l10n
                        .confirm, // "Confirmar" (chave já existente no @@Common)
                    onPressed: onConfirm,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
