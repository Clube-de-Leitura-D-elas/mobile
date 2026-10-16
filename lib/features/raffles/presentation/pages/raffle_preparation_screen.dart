import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/raffles/presentation/cubit/raffle_preparation_cubit.dart';
import 'package:mobile/features/raffles/presentation/cubit/raffle_preparation_state.dart';
import 'package:mobile/features/raffles/presentation/widgets/confirm_raffle_dialog.dart';
import 'package:mobile/features/raffles/presentation/widgets/raffle_participant_tile.dart';

class RafflePreparationScreen extends StatelessWidget {
  final String meetingId;

  const RafflePreparationScreen({super.key, required this.meetingId});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;

    return Scaffold(
      backgroundColor: colors.bgDefault,
      body: SafeArea(
        child: BlocConsumer<RafflePreparationCubit, RafflePreparationState>(
          listener: (context, state) {
            if (state is RafflePreparationError) {
              context.showAppToast(state.message);
            } else if (state is RafflePreparationSuccess) {
              context.showAppToast('Sorteio realizado com sucesso!');
              Navigator.of(context).pop();
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
              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: spacing.s24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Gap(32),
                          Text(
                            context
                                .l10n
                                .rafflePreparationTitle, // "Realizar sorteio"
                            style: typography.headingH2.copyWith(
                              color: colors.textDefault,
                            ),
                          ),
                          const Gap4(),
                          Text(
                            context
                                .l10n
                                .rafflePreparationSubtitle, // "Selecione as participantes"
                            style: typography.bodyDefault.copyWith(
                              color: colors.textMuted,
                            ),
                          ),
                          const Gap24(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                context.l10n.raffleTableHeaderName, // "Nome"
                                style: typography.bodySmall.copyWith(
                                  color: colors.textDefault,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                context
                                    .l10n
                                    .raffleTableHeaderInclude, // "Incluir no sorteio"
                                style: typography.bodySmall.copyWith(
                                  color: colors.textDefault,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const Gap12(),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: state.participants.length,
                            itemBuilder: (context, index) {
                              final participant = state.participants[index];
                              return RaffleParticipantTile(
                                participant: participant,
                                onChanged: (_) {
                                  context
                                      .read<RafflePreparationCubit>()
                                      .toggleParticipantSelection(
                                        participant.id,
                                      );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(spacing.s24),
                    child: Row(
                      children: [
                        Expanded(
                          child: AppButton.secondary(
                            label: context
                                .l10n
                                .back, // "Voltar" (chave já existente no @@Auth/Common)
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                        const Gap16(),
                        Expanded(
                          child: AppButton.primary(
                            label: context
                                .l10n
                                .continueAction, // "Continuar" (chave já existente no @@Common)
                            onPressed: state.isSubmitting
                                ? null
                                : () async {
                                    final confirmed =
                                        await ConfirmRaffleDialog.show(context);
                                    if (confirmed == true && context.mounted) {
                                      await context
                                          .read<RafflePreparationCubit>()
                                          .confirmRaffle(meetingId);
                                    }
                                  },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
