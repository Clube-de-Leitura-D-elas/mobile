import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/group_discovery/domain/entities/discovery_group_entity.dart';
import 'package:mobile/features/group_discovery/presentation/widgets/public_group_membership_section.dart';
import 'package:mobile/features/groups/presentation/widgets/app_group_avatar.dart';
import 'package:mobile/features/groups/presentation/widgets/group_metadata.dart';

class GroupSearchCard extends StatelessWidget {
  final DiscoveryGroupEntity group;
  final bool isRequesting;
  final VoidCallback onOpenDetails;
  final VoidCallback onRequestJoin;

  const GroupSearchCard({
    super.key,
    required this.group,
    required this.isRequesting,
    required this.onOpenDetails,
    required this.onRequestJoin,
  });

  static const double _avatarSize = 64;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;
    final l10n = context.l10n;
    final cityState = group.cityState;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(
              child: AppGroupAvatar(
                photoUrl: group.photoUrl,
                diameter: _avatarSize,
              ),
            ),
            SizedBox(width: spacing.s12),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.groupDetailsNumberLabel(group.number),
                      style: typography.headingH3.copyWith(
                        color: colors.textDefault,
                      ),
                    ),
                    SizedBox(height: spacing.s4),
                    GroupMetadata(
                      icon: AppIcons.group,
                      label: l10n.groupParticipantsCount(
                        group.participantCount,
                      ),
                      maxWidth: constraints.maxWidth,
                    ),
                    if (cityState != null) ...[
                      SizedBox(height: spacing.s4),
                      GroupMetadata(
                        icon: AppIcons.location,
                        label: cityState,
                        maxWidth: constraints.maxWidth,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            SizedBox(width: spacing.s8),
            _SeeDetailsLink(number: group.number, onTap: onOpenDetails),
          ],
        ),
        SizedBox(height: spacing.s12),
        PublicGroupMembershipSection(
          status: group.membershipStatus,
          isRequesting: isRequesting,
          onRequestJoin: onRequestJoin,
          buttonSize: AppButtonSize.md,
        ),
      ],
    );
  }
}

class _SeeDetailsLink extends StatelessWidget {
  final int number;
  final VoidCallback onTap;

  const _SeeDetailsLink({required this.number, required this.onTap});

  static const double _minTouchSize = 48;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Semantics(
      button: true,
      label: l10n.groupSearchSeeDetailsSemantic(number),
      onTap: onTap,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(context.spacing.s8),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: _minTouchSize,
            minWidth: _minTouchSize,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: context.spacing.s4),
            child: Center(
              widthFactor: 1,
              child: Text(
                l10n.groupSearchSeeDetails,
                style: context.typography.bodySmallEmphasis.copyWith(
                  color: context.colors.textBrand,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
