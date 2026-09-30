import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/domain/entities/group_meeting.dart';
import 'package:mobile/features/groups/presentation/widgets/event_history_book_cover.dart';

class EventHistoryCard extends StatelessWidget {
  const EventHistoryCard({
    super.key,
    required this.meeting,
    this.onDetailsPressed,
  });

  final GroupMeeting meeting;
  final VoidCallback? onDetailsPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;
    final l10n = context.l10n;
    final parsedDate = DateTime.tryParse(meeting.date);
    final date = parsedDate == null
        ? meeting.date
        : DateFormat(
            'dd/MM/yyyy',
            Localizations.localeOf(context).toString(),
          ).format(parsedDate.toLocal());

    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EventHistoryBookCover(imageUrl: meeting.bookCoverUrl),
          SizedBox(width: spacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meeting.bookTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: typography.bodyDefaultEmphasis.copyWith(
                    color: colors.textDefault,
                  ),
                ),
                SizedBox(height: spacing.s4),
                Text(
                  l10n.groupEventHistoryHost(meeting.hostName),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: typography.bodySmall.copyWith(color: colors.textMuted),
                ),
                SizedBox(height: spacing.s4),
                Text(
                  date,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: typography.bodySmall.copyWith(color: colors.textMuted),
                ),
                SizedBox(height: spacing.s12),
                Align(
                  alignment: Alignment.centerRight,
                  child: Semantics(
                    button: true,
                    enabled: true,
                    label: l10n.groupEventHistoryDetailsLink,
                    child: InkWell(
                      onTap: onDetailsPressed ?? () {},
                      borderRadius: BorderRadius.circular(spacing.s4),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: spacing.s4),
                        child: Text(
                          l10n.groupEventHistoryDetailsLink,
                          style: typography.bodySmallEmphasis.copyWith(
                            color: colors.textBrand,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
