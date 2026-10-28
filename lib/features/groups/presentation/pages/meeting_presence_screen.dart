import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
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
          Expanded(
            child: attendees.isEmpty
                ? const _EmptyAttendeesState()
                : Opacity(
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
              child: readOnly
                  ? const SizedBox.shrink()
                  : SizedBox(
                      width: double.infinity,
                      child: AppButton.primary(
                        label: context.l10n.confirm,
                        onPressed: isSubmitting ? null : cubit.confirm,
                        isLoading: isSubmitting,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyAttendeesState extends StatelessWidget {
  const _EmptyAttendeesState();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.spacing.s24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.groups_outlined, size: 48, color: colors.textMuted),
            SizedBox(height: context.spacing.s16),
            Text(
              context.l10n.meetingPresenceEmptyTitle,
              style: typography.bodyDefault.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.spacing.s8),
            Text(
              context.l10n.meetingPresenceEmptyDescription,
              style: typography.bodyDefault.copyWith(color: colors.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
