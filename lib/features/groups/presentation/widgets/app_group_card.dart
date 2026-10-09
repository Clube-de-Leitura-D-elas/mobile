import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/domain/entities/group_meeting.dart';
import 'package:mobile/features/groups/presentation/routes/group_routes.dart';
import 'package:mobile/features/groups/presentation/widgets/app_group_avatar.dart';
import 'package:mobile/features/groups/presentation/widgets/app_group_info_row.dart';

class AppGroupCard extends StatelessWidget {
  final String groupId;
  final String groupName;
  final String? photoUrl;
  final int participantsCount;
  final String cityState;
  final GroupMeeting? nextMeeting;
  final bool expanded;
  final VoidCallback? onTap;
  final VoidCallback? onToggleExpanded;
  final VoidCallback? onConfirmPresence;
  final VoidCallback? onDeclinePresence;
  final bool showPresenceActions;

  const AppGroupCard({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.participantsCount,
    required this.cityState,
    this.photoUrl,
    this.nextMeeting,
    this.expanded = true,
    this.onTap,
    this.onToggleExpanded,
    this.onConfirmPresence,
    this.onDeclinePresence,
    this.showPresenceActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final meeting = nextMeeting;

    return AppCard(
      showBorder: false,
      onTap:
          onTap ??
          () => context.push(
            Uri(
              path: GroupRoutes.groupDetails,
              queryParameters: {'group_id': groupId},
            ).toString(),
          ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _GroupCardHeader(
            photoUrl: photoUrl,
            groupName: groupName,
            participantsCount: participantsCount,
            cityState: cityState,
          ),
          if (meeting != null) ...[
            SizedBox(height: spacing.s16),
            _MeetingHeaderRow(
              expanded: expanded,
              onToggleExpanded: onToggleExpanded,
            ),
            if (expanded) ...[
              SizedBox(height: spacing.s8),
              _MeetingDetailsGrid(meeting: meeting),
              SizedBox(height: spacing.s16),
              if (showPresenceActions)
                _MeetingActionButtons(
                  onConfirmPresence: onConfirmPresence,
                  onDeclinePresence: onDeclinePresence,
                ),
            ],
          ],
        ],
      ),
    );
  }
}

class _GroupCardHeader extends StatelessWidget {
  final String? photoUrl;
  final String groupName;
  final int participantsCount;
  final String cityState;

  const _GroupCardHeader({
    required this.photoUrl,
    required this.groupName,
    required this.participantsCount,
    required this.cityState,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final l10n = context.l10n;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppGroupAvatar(photoUrl: photoUrl),
        SizedBox(width: spacing.s12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                groupName,
                style: typography.headingH2.copyWith(color: colors.textDefault),
              ),
              SizedBox(height: spacing.s4),
              AppGroupInfoRow(
                icon: AppIcons.group,
                label: l10n.groupParticipantsCount(participantsCount),
              ),
              AppGroupInfoRow(icon: AppIcons.location, label: cityState),
            ],
          ),
        ),
      ],
    );
  }
}

class _MeetingHeaderRow extends StatelessWidget {
  final bool expanded;
  final VoidCallback? onToggleExpanded;

  const _MeetingHeaderRow({
    required this.expanded,
    required this.onToggleExpanded,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final l10n = context.l10n;

    return Semantics(
      button: true,
      expanded: expanded,
      label: l10n.groupNextMeetingLabel,
      child: InkWell(
        onTap: onToggleExpanded,
        borderRadius: BorderRadius.circular(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.groupNextMeetingLabel,
              style: typography.bodyLarge.copyWith(color: colors.textMuted),
            ),
            Icon(
              expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: colors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class _MeetingDetailsGrid extends StatelessWidget {
  final GroupMeeting meeting;

  const _MeetingDetailsGrid({required this.meeting});

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

class _MeetingActionButtons extends StatelessWidget {
  final VoidCallback? onConfirmPresence;
  final VoidCallback? onDeclinePresence;

  const _MeetingActionButtons({
    required this.onConfirmPresence,
    required this.onDeclinePresence,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final l10n = context.l10n;

    return Row(
      children: [
        Expanded(
          child: AppButton.secondary(
            size: AppButtonSize.sm,
            label: l10n.groupDeclineMeetingButton,
            onPressed: onDeclinePresence ?? () {},
          ),
        ),
        SizedBox(width: spacing.s8),
        Expanded(
          child: AppButton.primary(
            size: AppButtonSize.sm,
            label: l10n.groupConfirmMeetingButton,
            onPressed: onConfirmPresence ?? () {},
          ),
        ),
      ],
    );
  }
}
