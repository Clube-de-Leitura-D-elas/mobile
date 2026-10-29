import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/domain/entities/group_meeting.dart';
import 'package:mobile/features/groups/presentation/routes/group_routes.dart';

class GroupCardMyTasksButton extends StatelessWidget {
  final GroupMeeting meeting;

  /// Substitui a navegação padrão para "Suas tarefas".
  final VoidCallback? onPressed;

  /// Chamado ao voltar de "Suas tarefas", para atualizar o contador.
  final VoidCallback? onClosed;

  const GroupCardMyTasksButton({
    super.key,
    required this.meeting,
    this.onPressed,
    this.onClosed,
  });

  Future<void> _openTasks(BuildContext context) async {
    await context.push<Object?>(
      Uri(
        path: GroupRoutes.meetingTasks,
        queryParameters: {if (meeting.id != null) 'meeting_id': meeting.id!},
      ).toString(),
    );
    onClosed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final l10n = context.l10n;
    final borderRadius = BorderRadius.circular(999);

    return Semantics(
      container: true,
      button: true,
      label:
          '${l10n.groupMeetingMyTasksAction}, '
          '${l10n.groupMeetingMyTasksProgress(meeting.tasksDone, meeting.tasksTotal)}',
      excludeSemantics: true,
      child: Material(
        color: colors.actionPrimary,
        borderRadius: borderRadius,
        child: InkWell(
          onTap: onPressed ?? () => _openTasks(context),
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
