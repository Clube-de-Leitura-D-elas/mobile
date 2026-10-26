import 'package:flutter/material.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';

class ConcludeMeetingDialog extends StatelessWidget {
  const ConcludeMeetingDialog({super.key});

  /// Retorna `true` só quando a anfitriã responde "Sim"; "Não", o "x" e tocar
  /// fora do modal retornam `false`/`null`.
  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => const ConcludeMeetingDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final l10n = context.l10n;

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
              children: [
                Expanded(
                  child: Text(
                    l10n.meetingTasksConcludeDialogTitle,
                    style: typography.headingH3.copyWith(
                      color: colors.textDefault,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Gap16(),
                SizedBox(
                  width: 48,
                  height: 48,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).closeButtonTooltip,
                    onPressed: () => Navigator.of(context).pop(false),
                    icon: Icon(
                      Icons.close,
                      color: colors.textDefault,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const Gap16(),
            Text(
              l10n.meetingTasksConcludeDialogMessage,
              style: typography.bodyDefault.copyWith(color: colors.textMuted),
            ),
            const Gap24(),
            Row(
              children: [
                Expanded(
                  child: AppButton.secondary(
                    label: l10n.meetingTasksConcludeDialogNo,
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ),
                const Gap16(),
                Expanded(
                  child: AppButton.primary(
                    label: l10n.meetingTasksConcludeDialogYes,
                    onPressed: () => Navigator.of(context).pop(true),
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
