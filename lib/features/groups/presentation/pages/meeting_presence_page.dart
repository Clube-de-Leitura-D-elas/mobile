import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/widgets/app_toast.dart';
import 'package:mobile/design_system/widgets/screen_header.dart';
import 'package:mobile/features/groups/domain/entities/meeting_presence_status.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_presence_cubit.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_presence_state.dart';
import 'package:mobile/features/groups/presentation/pages/meeting_presence_screen.dart';
import 'package:mobile/features/groups/presentation/widgets/group_error_state.dart';
import 'package:mobile/features/groups/presentation/group_failure_message.dart';

class MeetingPresencePage extends StatelessWidget {
  const MeetingPresencePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<MeetingPresenceCubit, MeetingPresenceState>(
      listenWhen: (prev, curr) =>
          (curr is MeetingPresenceEditing &&
              curr.submitError != null &&
              (prev is! MeetingPresenceEditing ||
                  prev.submitError != curr.submitError)) ||
          (curr is MeetingPresenceClosed && curr.confirmed),
      listener: (context, state) {
        if (state is MeetingPresenceClosed && state.confirmed) {
          Navigator.of(context).pop(
            state.attendees
                .where((a) => a.presenceStatus == MeetingPresenceStatus.present)
                .toList(),
          );
          return;
        }

        final error = (state as MeetingPresenceEditing).submitError!;
        context.showErrorToast(groupFailureMessage(context.l10n, error));
      },
      child: BlocBuilder<MeetingPresenceCubit, MeetingPresenceState>(
        builder: (context, state) => switch (state) {
          MeetingPresenceLoading() => Scaffold(
            appBar: ScreenHeader.back(
              title: context.l10n.meetingPresenceHeader,
            ),
            body: const Center(child: CircularProgressIndicator()),
          ),
          MeetingPresenceError(:final failure) => Scaffold(
            appBar: ScreenHeader.back(
              title: context.l10n.meetingPresenceHeader,
            ),
            body: GroupErrorState(
              failure: failure,
              onRetry: context.read<MeetingPresenceCubit>().retry,
            ),
          ),
          MeetingPresenceEditing() => MeetingPresenceScreen(
            attendees: state.attendees,
            marked: state.marked,
            isSubmitting: state.isSubmitting,
            readOnly: false,
          ),
          MeetingPresenceClosed(:final attendees) => MeetingPresenceScreen(
            attendees: attendees,
            marked: {
              for (final a in attendees)
                if (a.presenceStatus == MeetingPresenceStatus.present) a.id,
            },
            isSubmitting: false,
            readOnly: true,
          ),
        },
      ),
    );
  }
}
