import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/meeting_guest_requests/domain/entities/guest_request_decision.dart';

class ReviewGuestRequestDialog extends StatelessWidget {
  final GuestRequestDecision decision;
  final String name;

  const ReviewGuestRequestDialog({
    super.key,
    required this.decision,
    required this.name,
  });

  /// `true` só quando quem decide confirma; cancelar, o "x" e tocar fora
  /// do modal devolvem `false`/`null`.
  static Future<bool?> show(
    BuildContext context, {
    required GuestRequestDecision decision,
    required String name,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => ReviewGuestRequestDialog(decision: decision, name: name),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final navigator = Navigator.of(context);
    final isApprove = decision == GuestRequestDecision.approve;

    return AppDialog(
      title: isApprove
          ? l10n.meetingGuestRequestsApproveDialogTitle
          : l10n.meetingGuestRequestsRejectDialogTitle,
      onClose: () => navigator.pop(false),
      actions: [
        AppButton.secondary(
          label: l10n.meetingGuestRequestsDialogCancel,
          size: AppButtonSize.lg,
          onPressed: () => navigator.pop(false),
        ),
        if (isApprove)
          AppButton.primary(
            label: l10n.meetingGuestRequestsApprove,
            size: AppButtonSize.lg,
            onPressed: () => navigator.pop(true),
          )
        else
          AppButton.danger(
            label: l10n.meetingGuestRequestsReject,
            size: AppButtonSize.lg,
            onPressed: () => navigator.pop(true),
          ),
      ],
      child: Text(
        isApprove
            ? l10n.meetingGuestRequestsApproveDialogMessage(name)
            : l10n.meetingGuestRequestsRejectDialogMessage(name),
        style: context.typography.bodyDefault.copyWith(
          color: context.colors.textMuted,
        ),
      ),
    );
  }
}
