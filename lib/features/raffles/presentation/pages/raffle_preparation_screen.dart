import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/presentation/widgets/meeting_tasks/meeting_tasks_error_view.dart';
import 'package:mobile/features/raffles/domain/entities/raffle_participant.dart';
import 'package:mobile/features/raffles/presentation/cubit/raffle_preparation_cubit.dart';
import 'package:mobile/features/raffles/presentation/cubit/raffle_preparation_state.dart';
import 'package:mobile/features/raffles/presentation/routes/raffle_routes.dart';
import 'package:mobile/features/raffles/presentation/widgets/confirm_raffle_dialog.dart';
import 'package:mobile/features/raffles/presentation/widgets/raffle_participant_tile.dart';

class RafflePreparationScreen extends StatelessWidget {
  final String meetingId;
  final String meetingTitle;

  const RafflePreparationScreen({
    super.key,
    required this.meetingId,
    this.meetingTitle = '',
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    return Scaffold(
      backgroundColor: colors.bgDefault,
      body: SafeArea(
        child: BlocConsumer<RafflePreparationCubit, RafflePreparationState>(
          listenWhen: (previous, current) =>
              current is! RafflePreparationError ||
              previous is RafflePreparationLoaded,
          listener: (context, state) {
            if (state is RafflePreparationError) {
              context.showAppToast(context.l10n.raffleErrorMessage);
            } else if (state is RafflePreparationSuccess) {
              _openDraw(context, state.selectedParticipants);
            }
          },
          builder: (context, state) {
            if (state is RafflePreparationLoading) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colors.actionPrimary,
                  ),
                ),
              );
            }

            if (state is RafflePreparationLoaded) {
              final hasSelected = state.participants.any((p) => p.isSelected);

              return Column(
                children: [
                  Expanded(
                    child: CustomScrollView(
                      slivers: [
                        SliverPadding(
                          padding: EdgeInsets.symmetric(
                            horizontal: spacing.s24,
                          ),
                          sliver: const SliverToBoxAdapter(
                            child: _RaffleHeader(),
                          ),
                        ),
                        SliverPadding(
                          padding: EdgeInsets.symmetric(
                            horizontal: spacing.s24,
                          ),
                          sliver: _ParticipantsTable(
                            participants: state.participants,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _ActionButtons(
                    isSubmitting: state.isSubmitting,
                    canConfirm: hasSelected,
                    onBack: () => Navigator.of(context).pop(),
                    onContinue: () async {
                      final confirmed = await ConfirmRaffleDialog.show(context);
                      if (confirmed == true && context.mounted) {
                        await context
                            .read<RafflePreparationCubit>()
                            .confirmRaffle(meetingId);
                      }
                    },
                  ),
                ],
              );
            }

            if (state is RafflePreparationError) {
              return MeetingTasksErrorView(
                message: context.l10n.raffleErrorMessage,
                onRetry: () => context
                    .read<RafflePreparationCubit>()
                    .loadEligibleParticipants(meetingId),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  // push + pop em vez de pushReplacement: no go_router, o pushReplacement
  // nunca completa o Future de quem abriu a preparação, e as tarefas do
  // encontro não recarregam depois do sorteio.
  Future<void> _openDraw(
    BuildContext context,
    List<RaffleParticipant> selected,
  ) async {
    try {
      await context.push<Object?>(
        RaffleRoutes.draw,
        extra: {
          'meeting_id': meetingId,
          'meeting_title': meetingTitle,
          'participants': selected,
        },
      );
    } catch (_) {
      // Sem GoRouter acima (telas isoladas): só fecha a preparação.
    }
    if (context.mounted) Navigator.of(context).pop();
  }
}

class _RaffleHeader extends StatelessWidget {
  const _RaffleHeader();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Gap(32),
        Text(
          context.l10n.rafflePreparationTitle,
          style: typography.headingH2.copyWith(color: colors.textDefault),
        ),
        const Gap4(),
        Text(
          context.l10n.rafflePreparationSubtitle,
          style: typography.bodyDefault.copyWith(color: colors.textMuted),
        ),
        const Gap24(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.l10n.raffleTableHeaderName,
              style: typography.bodySmall.copyWith(
                color: colors.textDefault,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              context.l10n.raffleTableHeaderInclude,
              style: typography.bodySmall.copyWith(
                color: colors.textDefault,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const Gap12(),
      ],
    );
  }
}

class _ParticipantsTable extends StatelessWidget {
  final List<RaffleParticipant> participants;

  const _ParticipantsTable({required this.participants});

  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      itemCount: participants.length,
      itemBuilder: (context, index) {
        final participant = participants[index];
        return RaffleParticipantTile(
          participant: participant,
          onChanged: (_) {
            context.read<RafflePreparationCubit>().toggleParticipantSelection(
              participant.id,
            );
          },
        );
      },
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final bool isSubmitting;
  final bool canConfirm;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  const _ActionButtons({
    required this.isSubmitting,
    required this.canConfirm,
    required this.onBack,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return Padding(
      padding: EdgeInsets.all(spacing.s24),
      child: Row(
        children: [
          Expanded(
            child: AppButton.secondary(
              label: context.l10n.back,
              onPressed: onBack,
            ),
          ),
          const Gap16(),
          Expanded(
            child: AppButton.primary(
              label: context.l10n.continueAction,
              onPressed: isSubmitting || !canConfirm ? null : onContinue,
            ),
          ),
        ],
      ),
    );
  }
}
