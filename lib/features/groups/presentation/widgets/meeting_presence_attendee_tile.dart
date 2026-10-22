import 'package:flutter/material.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/tokens/color_tokens.dart';
import 'package:mobile/design_system/tokens/typography_tokens.dart';
import 'package:mobile/features/groups/domain/entities/meeting_attendance_entity.dart';
import 'package:mobile/features/groups/domain/entities/meeting_invitation_status.dart';

class PresenceAttendeeTile extends StatelessWidget {
  const PresenceAttendeeTile({
    super.key,
    required this.attendee,
    required this.isChecked,
    required this.onChanged,
  });

  final MeetingAttendanceEntity attendee;
  final bool isChecked;
  final VoidCallback? onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hint = switch (attendee.invitationStatus) {
      MeetingInvitationStatus.confirmed => l10n.invitationConfirmed,
      MeetingInvitationStatus.pending => l10n.invitationNoResponse,
      MeetingInvitationStatus.declined => l10n.invitationDeclined,
    };

    return ListTile(
      leading: CircleAvatar(
        radius: 24,
        backgroundImage: attendee.photoUrl != null
            ? NetworkImage(attendee.photoUrl!)
            : null,
        child: attendee.photoUrl == null ? Text(attendee.name[0]) : null,
      ),
      title: Text(attendee.name, style: context.typography.bodyDefault),
      subtitle: Text(
        hint,
        style: context.typography.bodyDefault.copyWith(
          color: context.colors.textMuted,
        ),
      ),
      trailing: Checkbox(
        value: isChecked,
        onChanged: onChanged == null ? null : (_) => onChanged!(),
      ),
      onTap: onChanged,
    );
  }
}
