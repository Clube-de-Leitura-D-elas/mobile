import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/group_join_requests/domain/entities/join_request_decision.dart';

class ReviewJoinRequestDialog extends StatelessWidget {
  final JoinRequestDecision decision;
  final String name;

  const ReviewJoinRequestDialog({
    super.key,
    required this.decision,
    required this.name,
  });

  /// `true` só quando a coordenadora confirma; cancelar, o "x" e tocar fora
  /// do modal devolvem `false`/`null`.
  static Future<bool?> show(
    BuildContext context, {
    required JoinRequestDecision decision,
    required String name,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => ReviewJoinRequestDialog(decision: decision, name: name),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final navigator = Navigator.of(context);
    final isApprove = decision == JoinRequestDecision.approve;

    return AppDialog(
      title: isApprove
          ? l10n.groupJoinRequestsApproveDialogTitle
          : l10n.groupJoinRequestsRejectDialogTitle,
      onClose: () => navigator.pop(false),
      actions: [
        AppButton.secondary(
          label: l10n.groupJoinRequestsDialogCancel,
          onPressed: () => navigator.pop(false),
        ),
        if (isApprove)
          AppButton.primary(
            label: l10n.groupJoinRequestsApprove,
            onPressed: () => navigator.pop(true),
          )
        else
          AppButton.danger(
            label: l10n.groupJoinRequestsReject,
            onPressed: () => navigator.pop(true),
          ),
      ],
      child: Text(
        isApprove
            ? l10n.groupJoinRequestsApproveDialogMessage(name)
            : l10n.groupJoinRequestsRejectDialogMessage(name),
        style: context.typography.bodyDefault.copyWith(
          color: context.colors.textMuted,
        ),
      ),
    );
  }
}
