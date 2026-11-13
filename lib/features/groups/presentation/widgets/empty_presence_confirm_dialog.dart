import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';

/// Confirma o envio da lista de presença sem ninguém marcado: todas ficam com
/// falta e o registro não pode ser refeito depois.
class EmptyPresenceConfirmDialog extends StatelessWidget {
  const EmptyPresenceConfirmDialog({super.key});

  /// `true` só quando a anfitriã confirma; voltar, o "x" e tocar fora do
  /// modal devolvem `false`/`null`.
  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => const EmptyPresenceConfirmDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final navigator = Navigator.of(context);

    return AppDialog(
      title: l10n.meetingPresenceEmptyConfirmTitle,
      onClose: () => navigator.pop(false),
      actions: [
        AppButton.secondary(
          label: l10n.meetingPresenceEmptyConfirmCancel,
          size: AppButtonSize.lg,
          onPressed: () => navigator.pop(false),
        ),
        AppButton.primary(
          label: l10n.meetingPresenceEmptyConfirmConfirm,
          size: AppButtonSize.lg,
          onPressed: () => navigator.pop(true),
        ),
      ],
      child: Text(
        l10n.meetingPresenceEmptyConfirmMessage,
        style: context.typography.bodyDefault.copyWith(
          color: context.colors.textMuted,
        ),
      ),
    );
  }
}
