import 'package:flutter/material.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/domain/entities/meeting_tasks_entity.dart';

class MeetingTasksBanner extends StatelessWidget {
  const MeetingTasksBanner({super.key, required this.tasks});

  final MeetingTasksEntity tasks;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final l10n = context.l10n;
    final published = tasks.isPublished;
    final accent = published ? colors.feedbackSuccessDark : colors.textBrand;
    final subtitle = published
        ? l10n.meetingTasksPublishedMessage
        : [tasks.bookAuthor, tasks.groupName].nonNulls.join(' · ');

    return Container(
      key: ValueKey(published ? 'banner_published' : 'banner_drawn'),
      padding: EdgeInsets.all(spacing.s16),
      decoration: BoxDecoration(
        color: published
            ? colors.feedbackSuccessLight
            : colors.surfaceBrandSoft,
        borderRadius: BorderRadius.circular(AppCard.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            published
                ? l10n.meetingTasksPublishedLabel
                : l10n.meetingTasksDrawnLabel,
            style: typography.caption.copyWith(
              color: accent,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          SizedBox(height: spacing.s4),
          Text(
            published
                ? l10n.meetingTasksPublishedTitle
                : tasks.bookTitle ?? l10n.meetingTasksDrawnFallbackTitle,
            style: typography.headingH3.copyWith(
              color: published ? accent : colors.textDefault,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            SizedBox(height: spacing.s4),
            Text(
              subtitle,
              style: typography.bodySmall.copyWith(
                color: published ? accent : colors.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
