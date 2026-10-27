import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/domain/entities/meeting_tasks_entity.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_tasks_cubit.dart';
import 'package:mobile/features/groups/presentation/routes/group_routes.dart';
import 'package:mobile/features/groups/presentation/widgets/conclude_meeting_dialog.dart';
import 'package:mobile/features/groups/presentation/widgets/meeting_tasks/meeting_task_card.dart';
import 'package:mobile/features/groups/presentation/widgets/meeting_tasks/meeting_tasks_banner.dart';
import 'package:mobile/features/groups/presentation/widgets/meeting_tasks/meeting_tasks_conclude_footer.dart';

class MeetingTasksContent extends StatelessWidget {
  const MeetingTasksContent({
    super.key,
    required this.meetingId,
    required this.tasks,
  });

  final String meetingId;
  final MeetingTasksEntity tasks;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final l10n = context.l10n;
    final schedule = tasks.schedule;
    final record = tasks.record;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(spacing.s16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MeetingTasksBanner(tasks: tasks),
                SizedBox(height: spacing.s24),
                Text(
                  l10n.meetingTasksPendingCount(tasks.pendingTasks),
                  style: context.typography.bodyDefault.copyWith(
                    color: context.colors.textDefault,
                  ),
                ),
                SizedBox(height: spacing.s12),
                MeetingTaskCard(
                  key: const ValueKey('meeting_task_schedule'),
                  title: l10n.meetingTasksScheduleTitle,
                  description: schedule.done
                      ? _formatSchedule(schedule)
                      : l10n.meetingTasksSchedulePending,
                  state: schedule.done
                      ? MeetingTaskCardState.done
                      : MeetingTaskCardState.active,
                  actionLabel: l10n.meetingTasksScheduleAction,
                  onPressed: () => _openAndReload(
                    context,
                    Uri(
                      path: GroupRoutes.meetingEdit,
                      queryParameters: {'meeting_id': meetingId},
                    ).toString(),
                  ),
                ),
                SizedBox(height: spacing.s12),
                MeetingTaskCard(
                  key: const ValueKey('meeting_task_record'),
                  title: l10n.meetingTasksRecordTitle,
                  description: switch (record.status) {
                    MeetingRecordStatus.locked => l10n.meetingTasksRecordLocked,
                    MeetingRecordStatus.pending =>
                      l10n.meetingTasksRecordPending,
                    MeetingRecordStatus.draft => l10n.meetingTasksRecordDraft,
                    MeetingRecordStatus.published =>
                      l10n.meetingTasksRecordPublished,
                  },
                  state: switch (record.status) {
                    MeetingRecordStatus.locked => MeetingTaskCardState.locked,
                    MeetingRecordStatus.published => MeetingTaskCardState.done,
                    _ => MeetingTaskCardState.active,
                  },
                  tag: record.status == MeetingRecordStatus.draft
                      ? l10n.meetingTasksRecordDraftTag
                      : null,
                  actionLabel: l10n.meetingTasksRecordAction,
                  onPressed: () => _openAndReload(
                    context,
                    Uri(
                      path: GroupRoutes.meetingRecord,
                      queryParameters: {'meeting_id': meetingId},
                    ).toString(),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (!tasks.isConcluded)
          MeetingTasksConcludeFooter(
            enabled: tasks.canConclude,
            onPressed: () => _confirmConclusion(context),
          ),
      ],
    );
  }

  String _formatSchedule(MeetingScheduleTask schedule) {
    final date = schedule.date?.toLocal();
    final lines = <String>[
      if (date != null) _formatDate(date),
      if (schedule.location != null) schedule.location!,
    ];
    return lines.join('\n');
  }

  /// "Sábado, 22 de agosto · 15h" (ou "· 15h30" quando há minutos).
  static String _formatDate(DateTime date) {
    final day = DateFormat("EEEE, d 'de' MMMM", 'pt_BR').format(date);
    final hour = date.minute == 0
        ? '${date.hour}h'
        : '${date.hour}h${date.minute.toString().padLeft(2, '0')}';
    return '${day[0].toUpperCase()}${day.substring(1)} · $hour';
  }

  /// Abre uma das telas reutilizadas e, ao voltar, recarrega as tarefas para
  /// atualizar o estado e o contador.
  Future<void> _openAndReload(BuildContext context, String location) async {
    await context.push<Object?>(location);
    if (context.mounted) {
      await context.read<MeetingTasksCubit>().refresh();
    }
  }

  /// "Encerrar encontro": modal → lista de presença. O encontro só é
  /// encerrado quando a lista é concluída (ver `MeetingAttendancePage`);
  /// voltar dela não muda nada além de recarregar as tarefas.
  Future<void> _confirmConclusion(BuildContext context) async {
    final confirmed = await ConcludeMeetingDialog.show(context);
    if (confirmed != true || !context.mounted) return;

    final date = tasks.schedule.date?.toLocal();
    await context.push<bool>(
      Uri(
        path: GroupRoutes.meetingAttendance,
        queryParameters: {'meeting_id': meetingId},
      ).toString(),
      extra: {
        'meetingName':
            tasks.bookTitle ?? context.l10n.meetingDetailsTitleFallback,
        'formattedDate': date == null
            ? ''
            : DateFormat('dd/MM/yyyy', 'pt_BR').format(date),
        'concludeOnFinish': true,
      },
    );
    if (context.mounted) {
      await context.read<MeetingTasksCubit>().refresh();
    }
  }
}
