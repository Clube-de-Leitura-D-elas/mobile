import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_tasks_cubit.dart';
import 'package:mobile/features/groups/presentation/widgets/meeting_tasks/meeting_tasks_content.dart';
import 'package:mobile/features/groups/presentation/widgets/meeting_tasks/meeting_tasks_error_view.dart';

class MeetingTasksScreen extends StatelessWidget {
  const MeetingTasksScreen({super.key, required this.meetingId});

  final String meetingId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ScreenHeader.back(title: context.l10n.meetingTasksTitle),
      body: BlocBuilder<MeetingTasksCubit, MeetingTasksState>(
        builder: (context, state) => switch (state) {
          MeetingTasksLoading() => const Center(
            child: CircularProgressIndicator(),
          ),
          MeetingTasksError(:final message) => MeetingTasksErrorView(
            message: message,
            onRetry: () => context.read<MeetingTasksCubit>().load(),
          ),
          MeetingTasksLoaded(:final tasks) => MeetingTasksContent(
            meetingId: meetingId,
            tasks: tasks,
          ),
        },
      ),
    );
  }
}
