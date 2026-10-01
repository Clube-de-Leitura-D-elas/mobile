import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/domain/entities/meeting_details_entity.dart';
import 'package:mobile/features/groups/presentation/widgets/meeting_info_row.dart';

class MeetingInfoCard extends StatelessWidget {
  const MeetingInfoCard({
    super.key,
    required this.meeting,
    required this.title,
  });

  final MeetingDetailsEntity meeting;
  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;
    final l10n = context.l10n;
    final description = meeting.description;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: typography.headingH3.copyWith(color: colors.textDefault),
          ),
          SizedBox(height: spacing.s16),
          MeetingInfoRow(icon: AppIcons.calendar, label: _dateLabel(context)),
          SizedBox(height: spacing.s12),
          MeetingInfoRow(
            icon: AppIcons.book,
            label: l10n.meetingDetailsBook(meeting.bookTitle),
          ),
          SizedBox(height: spacing.s12),
          MeetingInfoRow(
            icon: AppIcons.user,
            label: l10n.meetingDetailsHost(meeting.hostName),
          ),
          SizedBox(height: spacing.s12),
          MeetingInfoRow(
            icon: AppIcons.location,
            label: _locationLabel(context),
          ),
          if (description != null && description.trim().isNotEmpty) ...[
            SizedBox(height: spacing.s24),
            Text(
              l10n.meetingDetailsDescriptionTitle,
              style: typography.bodyDefaultEmphasis.copyWith(
                color: colors.textDefault,
              ),
            ),
            SizedBox(height: spacing.s8),
            Text(
              description.trim(),
              key: const ValueKey('meeting-description'),
              style: typography.bodySmall.copyWith(color: colors.textMuted),
            ),
          ],
        ],
      ),
    );
  }

  String _dateLabel(BuildContext context) {
    final date = meeting.date;
    if (date == null) return context.l10n.meetingDetailsDateUndefined;

    final formatted = DateFormat(
      'dd/MM/yyyy',
      Localizations.localeOf(context).toString(),
    ).format(date.toLocal());
    return context.l10n.meetingDetailsDate(formatted);
  }

  String _locationLabel(BuildContext context) {
    final parts = [meeting.locationName, meeting.locationAddress]
        .whereType<String>()
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList(growable: false);

    if (parts.isEmpty) return context.l10n.meetingDetailsLocationUndefined;
    return context.l10n.meetingDetailsLocation(parts.join(' - '));
  }
}
