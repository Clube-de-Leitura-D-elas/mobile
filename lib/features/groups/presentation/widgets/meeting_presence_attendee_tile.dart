import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/domain/entities/meeting_attendance_entity.dart';
import 'package:mobile/features/groups/presentation/widgets/app_participant_avatar.dart';

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

    final hint = isChecked
        ? l10n.meetingPresencePresent
        : l10n.meetingPresenceAbsent;

    return Semantics(
      container: true,
      checked: isChecked,
      enabled: onChanged != null,
      label: [
        attendee.name,
        if (attendee.isGuest) l10n.meetingAttendanceGuestTag,
        hint,
      ].join(', '),
      onTap: onChanged,
      child: ExcludeSemantics(
        child: ListTile(
          leading: AppParticipantAvatar(photoUrl: attendee.photoUrl),
          title: Text(attendee.name, style: context.typography.bodyDefault),
          subtitle: Wrap(
            spacing: context.spacing.s8,
            runSpacing: context.spacing.s4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (attendee.isGuest)
                AppTag(label: l10n.meetingAttendanceGuestTag),
              Text(
                hint,
                style: context.typography.bodyDefault.copyWith(
                  color: context.colors.textMuted,
                ),
              ),
            ],
          ),
          trailing: Checkbox(
            value: isChecked,
            onChanged: onChanged == null ? null : (_) => onChanged!(),
          ),
          onTap: onChanged,
        ),
      ),
    );
  }
}
