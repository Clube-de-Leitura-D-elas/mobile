import 'package:flutter/material.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/presentation/widgets/participants/participant_avatar.dart';
import 'package:shimmer/shimmer.dart';

class GroupParticipantsSkeleton extends StatelessWidget {
  const GroupParticipantsSkeleton({super.key});

  static const int rowCount = 3;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      label: context.l10n.groupParticipantsLoading,
      child: ExcludeSemantics(
        child: Shimmer.fromColors(
          baseColor: colors.surfaceSunken,
          highlightColor: colors.bgSubtle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: context.spacing.s16,
            children: List.filled(rowCount, const _ParticipantSkeletonTile()),
          ),
        ),
      ),
    );
  }
}

class _ParticipantSkeletonTile extends StatelessWidget {
  const _ParticipantSkeletonTile();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    return SizedBox(
      height: ParticipantAvatar.size,
      child: Row(
        children: [
          Container(
            width: ParticipantAvatar.size,
            height: ParticipantAvatar.size,
            decoration: BoxDecoration(
              color: colors.surfaceSunken,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: spacing.s16),
          Container(
            width: 160,
            height: 20,
            decoration: BoxDecoration(
              color: colors.surfaceSunken,
              borderRadius: BorderRadius.circular(spacing.s4),
            ),
          ),
        ],
      ),
    );
  }
}
