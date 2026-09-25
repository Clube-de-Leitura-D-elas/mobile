import 'package:flutter/material.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/domain/entities/group_meeting.dart';
import 'package:mobile/features/groups/presentation/widgets/app_group_avatar.dart';
import 'package:mobile/features/groups/presentation/widgets/app_group_info_row.dart';

class AppGroupCard extends StatelessWidget {
  final String groupName;
  final String? photoUrl;
  final int participantsCount;
  final String cityState;
  final GroupMeeting? nextMeeting;
  final bool expanded;
  final VoidCallback? onTap;
  final VoidCallback? onConfirmPresence;
  final VoidCallback? onDeclinePresence;

  const AppGroupCard({
    super.key,
    required this.groupName,
    required this.participantsCount,
    required this.cityState,
    this.photoUrl,
    this.nextMeeting,
    this.expanded = true,
    this.onTap,
    this.onConfirmPresence,
    this.onDeclinePresence,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final meeting = nextMeeting;
    final l10n = context.l10n;

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
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
                      style: typography.headingH2.copyWith(
                        color: colors.textDefault,
                      ),
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
          ),
          if (meeting != null) ...[
            SizedBox(height: spacing.s16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.groupNextMeetingLabel,
                  style: typography.bodyLarge.copyWith(color: colors.textMuted),
                ),
                Icon(
                  expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: colors.textMuted,
                ),
              ],
            ),
            if (expanded) ...[
              SizedBox(height: spacing.s8),
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
                      label: meeting.date,
                    ),
                  ),
                  Expanded(
                    child: AppGroupInfoRow(
                      icon: AppIcons.location,
                      label: meeting.location,
                    ),
                  ),
                ],
              ),
              SizedBox(height: spacing.s16),
              Row(
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
              ),
            ],
          ],
        ],
      ),
    );
  }
}

// Exemplo de uso:
//
// AppGroupCard(
//   groupName: 'Grupo 27',
//   photoUrl: 'https://.../grupo27.jpg',
//   participantsCount: 18,
//   cityState: 'Porto Alegre, RS',
//   nextMeeting: const GroupMeeting(
//     hostName: 'Roberta',
//     bookTitle: 'Pequeno príncipe',
//     date: '29/08/2026',
//     location: 'Z Café TECNOPUC',
//   ),
//   expanded: false, // mostra só "Próximo encontro" + seta pra baixo
//   onTap: () => Navigator.pushNamed(context, '/grupo/27'),
// ),
