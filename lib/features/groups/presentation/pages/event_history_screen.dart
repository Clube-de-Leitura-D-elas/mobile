import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/domain/entities/group_meeting.dart';
import 'package:mobile/features/groups/presentation/routes/group_route_paths.dart';
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
      itemBuilder: (context, index) {
        final meetingId = meetings[index].id;
        return EventHistoryCard(
          meeting: meetings[index],
          onDetailsPressed: meetingId == null
              ? null
              : () => context.push(
                  Uri(
                    path: GroupRoutePaths.meetingDetails,
                    queryParameters: {'meeting_id': meetingId},
                  ).toString(),
                ),
        );
      },
    );
  }
}
