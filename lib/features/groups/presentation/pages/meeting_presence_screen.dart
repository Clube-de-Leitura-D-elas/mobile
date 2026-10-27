import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/tokens/color_tokens.dart';
import 'package:mobile/design_system/tokens/spacing_tokens.dart';
import 'package:mobile/design_system/widgets/screen_header.dart';
import 'package:mobile/features/groups/domain/entities/meeting_attendance_entity.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_presence_cubit.dart';
import 'package:mobile/features/groups/presentation/widgets/meeting_presence_attendee_tile.dart';

class MeetingPresenceScreen extends StatelessWidget {
  const MeetingPresenceScreen({
    super.key,
    required this.attendees,
    required this.marked,
    required this.isSubmitting,
    required this.readOnly,
  });

  final List<MeetingAttendanceEntity> attendees;
  final Set<String> marked;
  final bool isSubmitting;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MeetingPresenceCubit>();

    return Scaffold(
      appBar: ScreenHeader.back(title: context.l10n.meetingPresenceHeader),
      body: Column(
        children: [
          if (readOnly)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: context.spacing.s16,
                vertical: context.spacing.s12,
              ),
              color: context.colors.feedbackSuccessLight,
              child: Text(
                context.l10n.meetingPresenceConfirmed,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.colors.feedbackSuccessDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          Expanded(
            child: Opacity(
              opacity: readOnly ? 0.5 : 1,
              child: ListView.builder(
                itemCount: attendees.length,
                itemBuilder: (context, index) {
                  final attendee = attendees[index];
                  return PresenceAttendeeTile(
                    attendee: attendee,
                    isChecked: marked.contains(attendee.id),
                    onChanged: readOnly || isSubmitting
                        ? null
                        : () => cubit.toggle(attendee.id),
                  );
                },
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(context.spacing.s16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.pop(),
                      child: Text(context.l10n.back),
                    ),
                  ),
                  if (!readOnly) ...[
                    SizedBox(width: context.spacing.s16),
                    Expanded(
                      child: FilledButton(
                        onPressed: isSubmitting ? null : cubit.confirm,
                        child: isSubmitting
                            ? const SizedBox.square(
                                dimension: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(context.l10n.confirm),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
