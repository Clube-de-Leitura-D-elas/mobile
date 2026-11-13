import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/group_discovery/domain/entities/discovery_group_entity.dart';
import 'package:mobile/features/group_discovery/presentation/widgets/public_group_membership_section.dart';
import 'package:mobile/features/groups/presentation/widgets/group_cover.dart';
import 'package:mobile/features/groups/presentation/widgets/group_metadata.dart';

class PublicGroupContent extends StatelessWidget {
  final DiscoveryGroupEntity group;
  final bool isRequesting;
  final VoidCallback onRequestJoin;
  final VoidCallback onOpenMemberDetails;

  const PublicGroupContent({
    super.key,
    required this.group,
    required this.isRequesting,
    required this.onRequestJoin,
    required this.onOpenMemberDetails,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;
    final l10n = context.l10n;
    final name = l10n.groupDetailsNumberLabel(group.number);
    final photoUrl = group.photoUrl;
    final cityState = group.cityState;

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GroupCover(
              image: photoUrl == null ? null : NetworkImage(photoUrl),
              name: name,
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                spacing.s24,
                spacing.s16,
                spacing.s24,
                spacing.s24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      name,
                      style: typography.headingH2.copyWith(
                        color: colors.textDefault,
                      ),
                    ),
                  ),
                  if (group.genres.isNotEmpty) ...[
                    SizedBox(height: spacing.s8),
                    Wrap(
                      spacing: spacing.s8,
                      runSpacing: spacing.s8,
                      children: [
                        for (final genre in group.genres) AppTag(label: genre),
                      ],
                    ),
                  ],
                  SizedBox(height: spacing.s12),
                  LayoutBuilder(
                    builder: (context, constraints) => Wrap(
                      spacing: spacing.s24,
                      runSpacing: spacing.s8,
                      children: [
                        GroupMetadata(
                          icon: AppIcons.user,
                          label: l10n.groupParticipantsCount(
                            group.participantCount,
                          ),
                          maxWidth: constraints.maxWidth,
                        ),
                        if (cityState != null)
                          GroupMetadata(
                            icon: AppIcons.location,
                            label: cityState,
                            maxWidth: constraints.maxWidth,
                          ),
                      ],
                    ),
                  ),
                  if (group.description.trim().isNotEmpty) ...[
                    SizedBox(height: spacing.s16),
                    Text(
                      group.description,
                      style: typography.bodyDefault.copyWith(
                        color: colors.textDefault,
                      ),
                    ),
                  ],
                  SizedBox(height: spacing.s24),
                  PublicGroupMembershipSection(
                    status: group.membershipStatus,
                    isRequesting: isRequesting,
                    onRequestJoin: onRequestJoin,
                    onOpenMemberDetails: onOpenMemberDetails,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
