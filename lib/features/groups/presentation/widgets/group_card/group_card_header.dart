import 'package:flutter/material.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/presentation/widgets/app_group_avatar.dart';
import 'package:mobile/features/groups/presentation/widgets/app_group_info_row.dart';

class GroupCardHeader extends StatelessWidget {
  final String? photoUrl;
  final String groupName;
  final int participantsCount;
  final String cityState;

  const GroupCardHeader({
    super.key,
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
