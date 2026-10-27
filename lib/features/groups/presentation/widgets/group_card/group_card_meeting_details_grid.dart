import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/domain/entities/group_meeting.dart';
import 'package:mobile/features/groups/presentation/widgets/app_group_info_row.dart';

class GroupCardMeetingDetailsGrid extends StatelessWidget {
  final GroupMeeting meeting;

  const GroupCardMeetingDetailsGrid({super.key, required this.meeting});

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final formattedDate = _formatMeetingDate(meeting.date);
    final l10n = context.l10n;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: AppGroupInfoRow(
                icon: AppIcons.user,
                label: meeting.hostName,
              ),
            ),
            Expanded(
              child: AppGroupInfoRow(
                icon: AppIcons.book,
                label: meeting.bookTitle,
              ),
            ),
          ],
        ),
        SizedBox(height: spacing.s4),
        Row(
          children: [
            Expanded(
              child: AppGroupInfoRow(
                icon: AppIcons.calendar,
                label: formattedDate,
              ),
            ),
            Expanded(
              child: AppGroupInfoRow(
                icon: AppIcons.location,
                label: meeting.location.isEmpty
                    ? l10n.groupNextEventNoLocation
                    : meeting.location,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

String _formatMeetingDate(String value) {
  final date = DateTime.tryParse(value);
  if (date == null) return value;

  return DateFormat('dd/MM/yyyy', 'pt_BR').format(date.toLocal());
}
