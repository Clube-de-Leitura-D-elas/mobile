import 'package:flutter/material.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/domain/entities/group_meeting.dart';

class GroupCardMyTasksButton extends StatelessWidget {
  final GroupMeeting meeting;
  final VoidCallback onPressed;

  const GroupCardMyTasksButton({
    super.key,
    required this.meeting,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final l10n = context.l10n;
    final borderRadius = BorderRadius.circular(999);

    return Semantics(
      button: true,
      label:
          '${l10n.groupMeetingMyTasksAction}, '
          '${l10n.groupMeetingMyTasksProgress(meeting.tasksDone, meeting.tasksTotal)}',
      excludeSemantics: true,
      child: Material(
        color: colors.actionPrimary,
        borderRadius: borderRadius,
        child: InkWell(
          onTap: onPressed,
          borderRadius: borderRadius,
          child: SizedBox(
            width: double.infinity,
            height: 40,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  l10n.groupMeetingMyTasksAction,
                  style: typography.bodyDefaultEmphasis.copyWith(
                    color: colors.textOnBrand,
                  ),
                ),
                Positioned(
                  right: spacing.s8,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: spacing.s8,
                      vertical: spacing.s4,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surfaceDefault.withValues(alpha: 0.7),
                      borderRadius: borderRadius,
                    ),
                    child: Text(
                      '${meeting.tasksDone}/${meeting.tasksTotal}',
                      style: typography.bodySmallEmphasis.copyWith(
                        color: colors.textDefault,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
