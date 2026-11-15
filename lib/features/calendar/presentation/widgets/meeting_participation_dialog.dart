import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';

class MeetingParticipationDialog extends StatelessWidget {
  final int groupNumber;

  const MeetingParticipationDialog({super.key, required this.groupNumber});

  /// `true` só quando a leitora confirma; cancelar, o "x" e tocar fora do
  /// modal devolvem `false`/`null`.
  static Future<bool?> show(BuildContext context, {required int groupNumber}) {
    return showDialog<bool>(
      context: context,
      builder: (_) => MeetingParticipationDialog(groupNumber: groupNumber),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final navigator = Navigator.of(context);

    return AppDialog(
      title: l10n.calendarGuestDialogTitle,
      onClose: () => navigator.pop(false),
      actions: [
        AppButton.secondary(
          label: l10n.calendarGuestDialogCancel,
          size: AppButtonSize.lg,
          onPressed: () => navigator.pop(false),
        ),
        AppButton.primary(
          label: l10n.calendarGuestDialogConfirm,
          size: AppButtonSize.lg,
          onPressed: () => navigator.pop(true),
        ),
      ],
      child: Text(
        l10n.calendarGuestDialogMessage(groupNumber),
        style: context.typography.bodyDefault.copyWith(
          color: context.colors.textMuted,
        ),
      ),
    );
  }
}
