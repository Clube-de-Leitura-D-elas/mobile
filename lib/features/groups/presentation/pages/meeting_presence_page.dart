import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/tokens/color_tokens.dart';
import 'package:mobile/design_system/tokens/spacing_tokens.dart';
import 'package:mobile/design_system/tokens/typography_tokens.dart';
import 'package:mobile/design_system/widgets/screen_header.dart';
import 'package:mobile/features/groups/domain/entities/meeting_presence_status.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_presence_cubit.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_presence_state.dart';
import 'package:mobile/features/groups/presentation/pages/meeting_presence_screen.dart';

class MeetingPresencePage extends StatelessWidget {
  const MeetingPresencePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<MeetingPresenceCubit, MeetingPresenceState>(
      listenWhen: (prev, curr) =>
          curr is MeetingPresenceEditing &&
          curr.submitError != null &&
          (prev is! MeetingPresenceEditing ||
              prev.submitError != curr.submitError),
      listener: (context, state) {
        final error = (state as MeetingPresenceEditing).submitError!;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
      },
      child: BlocBuilder<MeetingPresenceCubit, MeetingPresenceState>(
        builder: (context, state) => switch (state) {
          MeetingPresenceLoading() => Scaffold(
            appBar: ScreenHeader.back(
              title: context.l10n.meetingPresenceHeader,
            ),
            body: const Center(child: CircularProgressIndicator()),
          ),
          MeetingPresenceError(:final message) => Scaffold(
            appBar: ScreenHeader.back(
              title: context.l10n.meetingPresenceHeader,
            ),
            body: Center(
              child: Padding(
                padding: EdgeInsets.all(context.spacing.s24),
                child: Text(
                  message,
                  style: context.typography.bodyDefault.copyWith(
                    color: context.colors.textMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
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
