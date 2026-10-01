import 'package:flutter/material.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/domain/entities/meeting_details_entity.dart';
import 'package:mobile/features/groups/presentation/widgets/meeting_cover.dart';
import 'package:mobile/features/groups/presentation/widgets/meeting_info_card.dart';

class MeetingDetailsScreen extends StatelessWidget {
  const MeetingDetailsScreen({super.key, required this.meeting});

  final MeetingDetailsEntity meeting;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final l10n = context.l10n;
    final number = meeting.number;
    final title = number == null
        ? l10n.meetingDetailsTitleFallback
        : l10n.meetingDetailsTitle(number);
    final coverUrl = meeting.coverPhotoUrl;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MeetingCover(
              image: coverUrl == null ? null : NetworkImage(coverUrl),
              title: title,
            ),
            Padding(
              padding: EdgeInsets.all(spacing.s24),
              child: MeetingInfoCard(meeting: meeting, title: title),
            ),
          ],
        ),
      ),
    );
  }
}
