import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/domain/entities/group_participant_entity.dart';
import 'package:mobile/features/groups/presentation/cubit/group_participants_cubit.dart';
import 'package:mobile/features/groups/presentation/cubit/group_participants_state.dart';
import 'package:mobile/features/groups/presentation/widgets/participants/participant_avatar.dart';
import 'package:mobile/features/groups/presentation/widgets/participants/participant_tile.dart';
import 'package:shimmer/shimmer.dart';

/// Body of the "Participantes" section in the group details screen.
///
/// Rows are laid out in a [Column] on purpose: the screen already scrolls
/// (SingleChildScrollView) and groups have at most ~30 participants, so the
/// list scrolls with the page instead of competing with a nested scroll view.
class GroupParticipantsContent extends StatelessWidget {
  const GroupParticipantsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupParticipantsCubit, GroupParticipantsState>(
      builder: (context, state) => switch (state) {
        GroupParticipantsLoading() => const GroupParticipantsSkeleton(),
        GroupParticipantsError() => GroupParticipantsErrorView(
          onRetry: context.read<GroupParticipantsCubit>().retry,
        ),
        GroupParticipantsEmpty() => const GroupParticipantsEmptyView(),
        GroupParticipantsLoaded(:final participants) => GroupParticipantsList(
          participants: participants,
        ),
      },
    );
  }
}

class GroupParticipantsList extends StatelessWidget {
  final List<GroupParticipantEntity> participants;

  const GroupParticipantsList({super.key, required this.participants});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final participant in participants)
          ParticipantTile(
            key: ValueKey('participant-${participant.id}'),
            participant: participant,
          ),
      ],
    );
  }
}

class GroupParticipantsEmptyView extends StatelessWidget {
  const GroupParticipantsEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: spacing.s16),
      child: Text(
        context.l10n.groupParticipantsEmpty,
        style: context.text.bodyDefault.copyWith(color: colors.textMuted),
      ),
    );
  }
}

class GroupParticipantsErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const GroupParticipantsErrorView({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final l10n = context.l10n;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: spacing.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            liveRegion: true,
            child: Text(
              l10n.groupParticipantsLoadError,
              style: context.text.bodyDefault.copyWith(
                color: colors.textMuted,
              ),
            ),
          ),
          SizedBox(height: spacing.s12),
          AppButton.secondary(
            label: l10n.groupParticipantsRetryButton,
            size: AppButtonSize.sm,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}

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
            children: List.filled(rowCount, const ParticipantSkeletonTile()),
          ),
        ),
      ),
    );
  }
}

class ParticipantSkeletonTile extends StatelessWidget {
  const ParticipantSkeletonTile({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    return SizedBox(
      height: ParticipantTile.minHeight,
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
