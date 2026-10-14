import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/domain/entities/meeting_details_entity.dart';
import 'package:mobile/features/groups/presentation/routes/group_routes.dart';
import 'package:mobile/features/groups/presentation/widgets/meeting_cover.dart';
import 'package:mobile/features/groups/presentation/widgets/meeting_info_card.dart';
import 'package:mobile/features/groups/presentation/widgets/meeting_photos/meeting_photos_section.dart';
import 'package:mobile/features/groups/presentation/routes/group_route_paths.dart';

class MeetingDetailsScreen extends StatelessWidget {
  const MeetingDetailsScreen({
    super.key,
    required this.meeting,
    this.canEdit = false,
  });

  final MeetingDetailsEntity meeting;
  final bool canEdit;

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
      appBar: canEdit
          ? ScreenHeader.action(
              title: l10n.meetingDetailsHeader,
              action: IconButton(
                tooltip: l10n.meetingEditAction,
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => context.push(
                  Uri(
                    path: GroupRoutePaths.meetingEdit,
                    queryParameters: {'meeting_id': meeting.id},
                  ).toString(),
                  extra: meeting,
                ),
              ),
            )
          : null,
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
            Padding(
              padding: EdgeInsets.symmetric(horizontal: spacing.s24),
              child: AppButton.secondary(
                label: 'Ver lista de participantes',

                onPressed: () {
                  final meetingDate = meeting.date;

                  context.push(
                    '${GroupRoutes.meetingAttendance}?meeting_id=${meeting.id}',
                    extra: {
                      'meetingName': title,
                      'formattedDate': meetingDate != null
                          ? '${meetingDate.day.toString().padLeft(2, '0')}/'
                                '${meetingDate.month.toString().padLeft(2, '0')}/'
                                '${meetingDate.year}'
                          : '',
                    },
                  );
                },
              ),
            ),
            SizedBox(height: spacing.s16),
            SizedBox(height: spacing.s16),
            Padding(
              padding: EdgeInsets.fromLTRB(
                spacing.s24,
                0,
                spacing.s24,
                spacing.s24,
              ),
              child: const MeetingPhotosSection(),
            ),
          ],
        ),
      ),
    );
  }
}
