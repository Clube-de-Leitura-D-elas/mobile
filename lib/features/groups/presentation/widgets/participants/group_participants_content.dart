import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/domain/entities/group_participant_entity.dart';
import 'package:mobile/features/groups/presentation/cubit/group_participants_cubit.dart';
import 'package:mobile/features/groups/presentation/cubit/group_participants_state.dart';
import 'package:mobile/features/groups/presentation/widgets/participants/group_participants_error_view.dart';
import 'package:mobile/features/groups/presentation/widgets/participants/group_participants_skeleton.dart';
import 'package:mobile/features/groups/presentation/widgets/participants/participant_tile.dart';

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
        GroupParticipantsEmpty() => const _GroupParticipantsEmptyView(),
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
      spacing: context.spacing.s16,
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

class _GroupParticipantsEmptyView extends StatelessWidget {
  const _GroupParticipantsEmptyView();

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
