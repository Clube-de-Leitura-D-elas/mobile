import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/domain/entities/meeting_tasks_entity.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_tasks_cubit.dart';
import 'package:mobile/features/groups/presentation/routes/group_routes.dart';

class MeetingTasksScreen extends StatelessWidget {
  const MeetingTasksScreen({super.key, required this.meetingId});
  final String meetingId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ScreenHeader.back(title: 'Suas tarefas'),
      body: BlocBuilder<MeetingTasksCubit, MeetingTasksState>(
        builder: (context, state) => switch (state) {
          MeetingTasksLoading() => const Center(
            child: CircularProgressIndicator(),
          ),
          MeetingTasksError(:final message) => _ErrorView(
            message: message,
            onRetry: () async => context.read<MeetingTasksCubit>().load(),
          ),
          MeetingTasksLoaded(:final tasks) => _TasksContent(
            meetingId: meetingId,
            tasks: tasks,
          ),
        },
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: EdgeInsets.all(context.spacing.s24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          SizedBox(height: context.spacing.s16),
          AppButton.secondary(
            size: AppButtonSize.sm,
            label: 'Tentar novamente',
            onPressed: onRetry,
          ),
        ],
      ),
    ),
  );
}

class _TasksContent extends StatelessWidget {
  const _TasksContent({required this.meetingId, required this.tasks});
  final String meetingId;
  final MeetingTasksEntity tasks;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final canRecord = tasks.record.status != MeetingRecordStatus.locked;
    return Padding(
      padding: EdgeInsets.all(spacing.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Banner(tasks: tasks),
          SizedBox(height: spacing.s16),
          Text(
            '${tasks.completedTasks}/2 tarefas para você',
            style: context.typography.bodyDefaultEmphasis,
          ),
          SizedBox(height: spacing.s12),
          _TaskCard(
            title: '1. Marcar data e local',
            description: tasks.schedule.done
                ? _scheduleText(tasks.schedule)
                : 'O grupo está esperando para saber quando e onde.',
            done: tasks.schedule.done,
            actionLabel: 'Marcar agora',
            onPressed: tasks.schedule.done
                ? null
                : () async => _openEdit(context),
          ),
          SizedBox(height: spacing.s12),
          _TaskCard(
            title: '2. Enviar fotos do encontro',
            description: switch (tasks.record.status) {
              MeetingRecordStatus.locked =>
                'Disponível depois que o encontro acontecer.',
              MeetingRecordStatus.published => 'Registro publicado.',
              _ => 'Depois do encontro, compartilhe como foi.',
            },
            done: tasks.record.status == MeetingRecordStatus.published,
            actionLabel: 'Enviar fotos',
            onPressed:
                canRecord &&
                    tasks.record.status != MeetingRecordStatus.published
                ? () async => context.push(
                    '${GroupRoutes.meetingRecord}?meeting_id=$meetingId',
                  )
                : null,
            muted: !canRecord,
          ),
          const Spacer(),
          if (!tasks.canConclude)
            Padding(
              padding: EdgeInsets.only(bottom: spacing.s8),
              child: Text(
                'Este botão ficará ativo quando o encontro iniciar.',
                textAlign: TextAlign.center,
                style: context.typography.bodySmall.copyWith(
                  color: context.colors.textMuted,
                ),
              ),
            ),
          if (tasks.status != MeetingTaskStatus.concluded)
            AppButton.primary(
              label: 'Encerrar encontro',
              onPressed: tasks.canConclude
                  ? () => _confirmConclusion(context)
                  : null,
            ),
        ],
      ),
    );
  }

  String _scheduleText(MeetingScheduleTask schedule) {
    final date = schedule.date;
    final formattedDate = date == null
        ? ''
        : '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    return '$formattedDate${schedule.location == null ? '' : ' — ${schedule.location}'}';
  }

  Future<void> _openEdit(BuildContext context) async {
    await context.push('${GroupRoutes.meetingEdit}?meeting_id=$meetingId');
    if (context.mounted) {
      await context.read<MeetingTasksCubit>().load();
    }
  }

  Future<void> _confirmConclusion(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Encerrar encontro?'),
        content: const Text(
          'Você será direcionada para a lista de presença para concluir o encerramento.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Não'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sim'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.push(
        '${GroupRoutes.meetingAttendance}?meeting_id=$meetingId',
        extra: {'concludeOnFinish': true},
      );
      if (context.mounted) await context.read<MeetingTasksCubit>().load();
    }
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.tasks});
  final MeetingTasksEntity tasks;

  @override
  Widget build(BuildContext context) {
    final published = tasks.schedule.done;
    return Container(
      padding: EdgeInsets.all(context.spacing.s16),
      decoration: BoxDecoration(
        color: published ? const Color(0xffe1f6ed) : const Color(0xffffe8f0),
        borderRadius: BorderRadius.circular(context.spacing.s12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            published ? 'TUDO CERTO' : 'VOCÊ FOI SORTEADA',
            style: context.typography.bodySmallEmphasis.copyWith(
              color: published
                  ? context.colors.feedbackSuccess
                  : context.colors.textBrand,
            ),
          ),
          SizedBox(height: context.spacing.s4),
          Text(
            published ? 'Encontro publicado' : 'A anfitriã do encontro',
            style: context.typography.headingH3,
          ),
          if (published) const Text('As participantes já foram avisadas.'),
        ],
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.title,
    required this.description,
    required this.done,
    required this.actionLabel,
    required this.onPressed,
    this.muted = false,
  });
  final String title;
  final String description;
  final bool done;
  final String actionLabel;
  final VoidCallback? onPressed;
  final bool muted;

  @override
  Widget build(BuildContext context) => AppCard(
    showBorder: true,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: context.typography.bodyDefaultEmphasis.copyWith(
                  color: muted ? context.colors.textMuted : null,
                ),
              ),
            ),
            if (done)
              Icon(Icons.check_circle, color: context.colors.feedbackSuccess),
          ],
        ),
        SizedBox(height: context.spacing.s8),
        Text(
          description,
          style: context.typography.bodySmall.copyWith(
            color: muted ? context.colors.textMuted : null,
          ),
        ),
        if (onPressed != null) ...[
          SizedBox(height: context.spacing.s12),
          AppButton.primary(
            size: AppButtonSize.sm,
            label: actionLabel,
            onPressed: onPressed,
          ),
        ],
      ],
    ),
  );
}
