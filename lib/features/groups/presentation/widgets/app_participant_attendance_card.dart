import 'package:flutter/material.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/domain/entities/meeting_attendance_entity.dart';
import 'package:mobile/features/groups/domain/entities/meeting_invitation_status.dart';
import 'package:mobile/features/groups/domain/entities/meeting_presence_status.dart';
import 'package:mobile/features/groups/presentation/widgets/app_participant_avatar.dart';

class AppParticipantAttendanceCard extends StatelessWidget {
  final MeetingAttendanceEntity participant;

  const AppParticipantAttendanceCard({super.key, required this.participant});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;

    return AppCard(
      showBorder: true,
      child: Row(
        children: [
          AppParticipantAvatar(photoUrl: participant.photoUrl),
          SizedBox(width: spacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  participant.name,
                  style: typography.bodyDefaultEmphasis.copyWith(
                    color: colors.textDefault,
                  ),
                ),
                SizedBox(height: spacing.s8),
                Wrap(
                  spacing: spacing.s8,
                  runSpacing: spacing.s4,
                  children: [
                    AppTag(
                      label: _invitationLabel(participant.invitationStatus),
                      variant: _invitationVariant(participant.invitationStatus),
                    ),
                    AppTag(
                      label: _presenceLabel(participant.presenceStatus),
                      variant: _presenceVariant(participant.presenceStatus),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _invitationLabel(MeetingInvitationStatus status) {
    return switch (status) {
      MeetingInvitationStatus.confirmed => 'Confirmada',
      MeetingInvitationStatus.declined => 'Recusou',
      MeetingInvitationStatus.pending => 'Sem resposta',
    };
  }

  TagVariant _invitationVariant(MeetingInvitationStatus status) {
    return switch (status) {
      MeetingInvitationStatus.confirmed => TagVariant.success,
      MeetingInvitationStatus.declined => TagVariant.error,
      MeetingInvitationStatus.pending => TagVariant.neutral,
    };
  }

  String _presenceLabel(MeetingPresenceStatus? status) {
    return switch (status) {
      MeetingPresenceStatus.present => 'Presente',
      MeetingPresenceStatus.absent => 'Ausente',
      null => 'Não registrada',
    };
  }

  TagVariant _presenceVariant(MeetingPresenceStatus? status) {
    return switch (status) {
      MeetingPresenceStatus.present => TagVariant.success,
      MeetingPresenceStatus.absent => TagVariant.error,
      null => TagVariant.neutral,
    };
  }
}
