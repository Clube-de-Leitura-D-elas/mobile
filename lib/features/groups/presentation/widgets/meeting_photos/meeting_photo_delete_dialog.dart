import 'package:flutter/material.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';

class MeetingPhotoDeleteDialog extends StatelessWidget {
  const MeetingPhotoDeleteDialog({super.key});

  /// Retorna `true` só quando a participante confirma a remoção.
  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => const MeetingPhotoDeleteDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final l10n = context.l10n;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      backgroundColor: colors.bgDefault,
      child: Padding(
        padding: EdgeInsets.all(context.spacing.s24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.meetingPhotoDeleteDialogTitle,
              style: typography.headingH3.copyWith(
                color: colors.textDefault,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Gap16(),
            Text(
              l10n.meetingPhotoDeleteDialogMessage,
              style: typography.bodyDefault.copyWith(color: colors.textMuted),
            ),
            const Gap24(),
            Row(
              children: [
                Expanded(
                  child: AppButton.secondary(
                    label: l10n.meetingPhotoDeleteDialogCancel,
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ),
                const Gap16(),
                Expanded(
                  child: AppButton.danger(
                    key: const ValueKey('meeting-photo-delete-confirm'),
                    label: l10n.meetingPhotoDelete,
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
