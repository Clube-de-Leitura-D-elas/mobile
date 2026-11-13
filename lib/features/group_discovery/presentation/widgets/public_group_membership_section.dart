import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/group_discovery/domain/entities/group_membership_status.dart';
import 'package:mobile/features/group_discovery/presentation/widgets/membership_status_indicator.dart';

/// Situação da leitora e a ação que cabe a ela no grupo.
class PublicGroupMembershipSection extends StatelessWidget {
  final GroupMembershipStatus status;
  final bool isRequesting;
  final VoidCallback onRequestJoin;
  final VoidCallback onOpenMemberDetails;

  const PublicGroupMembershipSection({
    super.key,
    required this.status,
    required this.isRequesting,
    required this.onRequestJoin,
    required this.onOpenMemberDetails,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final spacing = context.spacing;

    final (String? label, Color color) = switch (status) {
      GroupMembershipStatus.none => (null, colors.textMuted),
      GroupMembershipStatus.requested => (
        l10n.publicGroupStatusRequested,
        colors.feedbackWarningDark,
      ),
      GroupMembershipStatus.rejected => (
        l10n.publicGroupStatusRejected,
        colors.feedbackErrorDark,
      ),
      GroupMembershipStatus.pending => (
        l10n.publicGroupStatusPending,
        colors.textMuted,
      ),
      GroupMembershipStatus.member => (
        l10n.publicGroupStatusMember,
        colors.textMuted,
      ),
    };

    final Widget? action = switch (status) {
      GroupMembershipStatus.none => AppButton.primary(
        label: l10n.publicGroupRequestJoin,
        size: AppButtonSize.lg,
        isLoading: isRequesting,
        onPressed: onRequestJoin,
      ),
      GroupMembershipStatus.rejected => AppButton.primary(
        label: l10n.publicGroupRequestAgain,
        size: AppButtonSize.lg,
        isLoading: isRequesting,
        onPressed: onRequestJoin,
      ),
      GroupMembershipStatus.member => AppButton.secondary(
        label: l10n.publicGroupOpenMemberDetails,
        size: AppButtonSize.lg,
        onPressed: onOpenMemberDetails,
      ),
      GroupMembershipStatus.requested || GroupMembershipStatus.pending => null,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (label != null)
          MembershipStatusIndicator(label: label, color: color),
        if (label != null && action != null) SizedBox(height: spacing.s16),
        ?action,
      ],
    );
  }
}
