import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/domain/entities/group_participant_entity.dart';
import 'package:mobile/features/groups/presentation/cubit/group_participants_cubit.dart';
import 'package:mobile/features/groups/presentation/cubit/group_participants_state.dart';
import 'package:mobile/features/groups/presentation/cubit/next_event_cubit.dart';
import 'package:mobile/features/groups/presentation/cubit/next_event_state.dart';
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
    final nextEventCubit = context.watch<NextEventCubit?>();
    final nextEventState = nextEventCubit?.state;
    final nextEventHostName = nextEventState is NextEventLoaded
        ? nextEventState.event.hostName.trim()
        : null;

    return BlocBuilder<GroupParticipantsCubit, GroupParticipantsState>(
      builder: (context, state) => switch (state) {
        GroupParticipantsLoading() => const GroupParticipantsSkeleton(),
        GroupParticipantsError() => GroupParticipantsErrorView(
          onRetry: context.read<GroupParticipantsCubit>().retry,
        ),
        GroupParticipantsEmpty() => const _GroupParticipantsEmptyView(),
        GroupParticipantsLoaded(:final participants) => _GroupParticipantsList(
          participants: participants,
          nextEventHostName: nextEventHostName,
        ),
      },
    );
  }
}

class _GroupParticipantsList extends StatelessWidget {
  final List<GroupParticipantEntity> participants;
  final String? nextEventHostName;

  const _GroupParticipantsList({
    required this.participants,
    this.nextEventHostName,
  });

  @override
  Widget build(BuildContext context) {
    final hostName = nextEventHostName;
    final hasExplicitHost = participants.any((p) => p.isHost);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: context.spacing.s16,
      children: [
        for (final participant in participants)
          ParticipantTile(
            key: ValueKey('participant-${participant.id}'),
            participant:
                !hasExplicitHost &&
                    hostName != null &&
                    hostName.isNotEmpty &&
                    participant.name.trim() == hostName
                ? GroupParticipantEntity(
                    id: participant.id,
                    name: participant.name,
                    photoUrl: participant.photoUrl,
                    isCoordinator: participant.isCoordinator,
                    isHost: true,
                  )
                : participant,
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
