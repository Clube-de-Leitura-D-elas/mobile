import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';

class JoinRequestDialog extends StatelessWidget {
  final int groupNumber;

  const JoinRequestDialog({super.key, required this.groupNumber});

  /// `true` só quando a leitora confirma; cancelar, o "x" e tocar fora do
  /// modal devolvem `false`/`null`.
  static Future<bool?> show(BuildContext context, {required int groupNumber}) {
    return showDialog<bool>(
      context: context,
      builder: (_) => JoinRequestDialog(groupNumber: groupNumber),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final navigator = Navigator.of(context);

    return AppDialog(
      title: l10n.publicGroupJoinDialogTitle,
      onClose: () => navigator.pop(false),
      actions: [
        AppButton.secondary(
          label: l10n.publicGroupJoinDialogCancel,
          onPressed: () => navigator.pop(false),
        ),
        AppButton.primary(
          label: l10n.publicGroupJoinDialogConfirm,
          onPressed: () => navigator.pop(true),
        ),
      ],
      child: Text(
        l10n.publicGroupJoinDialogMessage(groupNumber),
        style: context.typography.bodyDefault.copyWith(
          color: context.colors.textMuted,
        ),
      ),
    );
  }
}
