import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
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
    final l10n = context.l10n;
    final parsedDate = DateTime.tryParse(meeting.date)?.toLocal();
    final formattedDate = parsedDate == null
        ? meeting.date
        : DateFormat('dd/MM/yyyy', 'pt_BR').format(parsedDate);
    final formattedTime = parsedDate == null
        ? l10n.groupNextEventTimeUndefined
        : DateFormat('HH:mm', 'pt_BR').format(parsedDate);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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
                icon: AppIcons.clock,
                label: formattedTime,
              ),
            ),
          ],
        ),
        SizedBox(height: spacing.s4),
        Row(
          children: [
            Expanded(
              child: AppGroupInfoRow(
                icon: AppIcons.book,
                label: meeting.bookTitle,
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
