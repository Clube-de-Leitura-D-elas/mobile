import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/domain/entities/meeting_invitation_status.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_invitation_cubit.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_invitation_state.dart';
import 'package:mobile/features/groups/presentation/widgets/status_with_action_label.dart';

class AppMeetingResponseButtons extends StatelessWidget {
  const AppMeetingResponseButtons({super.key});

  void _handleConfirm(BuildContext context) {
    context.read<MeetingInvitationCubit>().respond(
      MeetingInvitationStatus.confirmed,
    );
  }

  void _handleDecline(BuildContext context) {
    context.read<MeetingInvitationCubit>().respond(
      MeetingInvitationStatus.declined,
    );
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final l10n = context.l10n;
    final colors = context.colors;

    return BlocBuilder<MeetingInvitationCubit, MeetingInvitationState>(
      builder: (context, state) {
        switch (state.currentStatus) {
          case MeetingInvitationStatus.pending:
            return Row(
              children: [
                Expanded(
                  child: AppButton.secondary(
                    size: AppButtonSize.sm,
                    label: l10n.groupDeclineMeetingButton,
                    onPressed: () => _handleDecline(context),
                  ),
                ),
                SizedBox(width: spacing.s8),
                Expanded(
                  child: AppButton.primary(
                    size: AppButtonSize.sm,
                    label: l10n.groupConfirmMeetingButton,
                    onPressed: () => _handleConfirm(context),
                  ),
                ),
              ],
            );

          case MeetingInvitationStatus.confirmed:
            return StatusWithActionLabel(
              statusLabel: l10n.groupMeetingConfirmedLabel,
              statusIcon: Icons.check_circle_outline,
              statusColor: colors.feedbackSuccess,
              action: AppButton.secondary(
                size: AppButtonSize.sm,
                label: l10n.groupDeclineMeetingButton,
                onPressed: () => _handleDecline(context),
              ),
            );

          case MeetingInvitationStatus.declined:
            return StatusWithActionLabel(
              statusLabel: l10n.groupMeetingDeclinedLabel,
              statusIcon: Icons.cancel_outlined,
              statusColor: colors.textMuted,
              action: AppButton.primary(
                size: AppButtonSize.sm,
                label: l10n.groupConfirmMeetingButton,
                onPressed: () => _handleConfirm(context),
              ),
            );
        }
      },
    );
  }
}
