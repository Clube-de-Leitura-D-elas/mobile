import 'package:flutter/material.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/domain/entities/meeting_attendance_entity.dart';
import 'package:mobile/features/groups/presentation/widgets/app_participant_attendance_card.dart';

class MeetingAttendanceScreen extends StatelessWidget {
  final String meetingName;
  final String formattedDate;
  final List<MeetingAttendanceEntity> participants;

  const MeetingAttendanceScreen({
    super.key,
    required this.meetingName,
    required this.formattedDate,
    required this.participants,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;

    return Scaffold(
      appBar: ScreenHeader.back(title: meetingName),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(spacing.s16),
            color: colors.bgSubtle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meetingName,
                  style: typography.headingH2.copyWith(
                    color: colors.textDefault,
                  ),
                ),
                SizedBox(height: spacing.s4),
                Text(
                  formattedDate,
                  style: typography.bodySmall.copyWith(color: colors.textMuted),
                ),
              ],
            ),
          ),
          Expanded(
            child: participants.isEmpty
                ? Center(
                    child: Text(
                      'Nenhuma participante no grupo.',
                      style: typography.bodyDefault.copyWith(
                        color: colors.textMuted,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.all(spacing.s16),
                    itemCount: participants.length,
                    separatorBuilder: (_, _) => SizedBox(height: spacing.s12),
                    itemBuilder: (context, index) {
                      return AppParticipantAttendanceCard(
                        participant: participants[index],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
