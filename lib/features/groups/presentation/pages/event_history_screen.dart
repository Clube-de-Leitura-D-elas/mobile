import 'package:flutter/material.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/domain/entities/group_meeting.dart';
import 'package:mobile/features/groups/presentation/widgets/event_history_card.dart';

class EventHistoryScreen extends StatelessWidget {
  const EventHistoryScreen({super.key, required this.meetings});

  final List<GroupMeeting> meetings;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return ListView.separated(
      padding: EdgeInsets.all(spacing.s24),
      itemCount: meetings.length,
      separatorBuilder: (_, _) => SizedBox(height: spacing.s16),
      itemBuilder: (_, index) => EventHistoryCard(meeting: meetings[index]),
    );
  }
}
