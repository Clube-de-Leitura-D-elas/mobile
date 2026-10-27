import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/raffles/presentation/cubit/raffle_execution_cubit.dart';
import 'package:mobile/features/raffles/presentation/cubit/raffle_execution_state.dart';
import 'package:mobile/features/raffles/presentation/pages/raffle_result_screen.dart';

class RaffleExecutionScreen extends StatelessWidget {
  final String meetingId;
  final String meetingTitle;

  const RaffleExecutionScreen({
    super.key,
    required this.meetingId,
    this.meetingTitle = '',
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.bgDefault,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: BlocBuilder<RaffleExecutionCubit, RaffleExecutionState>(
          builder: (context, state) => ScreenHeader.back(
            title: state is RaffleExecutionResultLoaded
                ? context.l10n.raffleResultTitle
                : context.l10n.raffleDrawScreenTitle,
          ),
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<RaffleExecutionCubit, RaffleExecutionState>(
          listener: (context, state) {
            if (state is RaffleExecutionError) {
              context.showAppToast(state.message);
            } else if (state is RaffleExecutionSuccess) {
              context.showAppToast(context.l10n.raffleSavedSuccessToast);
              Navigator.of(context).pop();
            }
          },
          builder: (context, state) {
            if (state is RaffleExecutionLoading) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colors.actionPrimary,
                  ),
                ),
              );
            }

            if (state is RaffleExecutionResultLoaded) {
              return RaffleResultScreen(
                result: state.result,
                isPersisted: state.isPersisted,
                isSubmitting: state.isSubmitting,
                onDrawAgain: () {
                  context.read<RaffleExecutionCubit>().draw();
                },
                onFinish: () {
                  if (state.isPersisted) {
                    Navigator.of(context).pop();
                  } else {
                    context.read<RaffleExecutionCubit>().confirmResult();
                  }
                },
              );
            }

            if (state is RaffleExecutionNoEligible) {
              return _NoEligibleView(
                meetingTitle: state.meetingTitle.isNotEmpty
                    ? state.meetingTitle
                    : meetingTitle,
              );
            }

            if (state is RaffleExecutionReady) {
              return _ReadyDrawView(
                state: state,
                onDraw: () => context.read<RaffleExecutionCubit>().draw(),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _ReadyDrawView extends StatelessWidget {
  final RaffleExecutionReady state;
  final VoidCallback onDraw;

  const _ReadyDrawView({required this.state, required this.onDraw});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;

    final title = state.meetingTitle.isNotEmpty
        ? context.l10n.raffleBookDrawTitle(state.meetingTitle)
        : context.l10n.raffleDrawScreenTitle;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: spacing.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Gap24(),
          Text(
            title,
            textAlign: TextAlign.center,
            style: typography.headingH2.copyWith(
              color: colors.textDefault,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Gap8(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.group_outlined, size: 20, color: colors.textMuted),
              const Gap8(),
              Text(
                context.l10n.groupParticipantsCount(
                  state.eligibleParticipants.length,
                ),
                style: typography.bodyDefault.copyWith(
                  color: colors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Spacer(),
          Center(
            child: _DrawCircleButton(isDrawing: state.isDrawing, onTap: onDraw),
          ),
          const Spacer(),
          Text(
            context.l10n.raffleDisclaimer,
            textAlign: TextAlign.center,
            style: typography.bodySmall.copyWith(
              color: colors.textMuted,
              height: 1.4,
            ),
          ),
          const Gap24(),
        ],
      ),
    );
  }
}

class _DrawCircleButton extends StatelessWidget {
  final bool isDrawing;
  final VoidCallback onTap;

  const _DrawCircleButton({required this.isDrawing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Semantics(
      button: true,
      label: context.l10n.raffleDrawButton,
      child: GestureDetector(
        onTap: isDrawing ? null : onTap,
        child: Container(
          width: 260,
          height: 260,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.bgDefault,
            border: Border.all(color: colors.actionPrimary, width: 2.0),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.25),
                offset: Offset(0, 4),
                blurRadius: 4,
              ),
            ],
          ),
          child: Center(
            child: isDrawing
                ? CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      colors.actionPrimary,
                    ),
                  )
                : Text(
                    context.l10n.raffleDrawButton,
                    textAlign: TextAlign.center,
                    style: typography.headingH1.copyWith(
                      color: colors.actionPrimary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _NoEligibleView extends StatelessWidget {
  final String meetingTitle;

  const _NoEligibleView({required this.meetingTitle});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;

    return Padding(
      padding: EdgeInsets.all(spacing.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          Icon(Icons.people_outline, size: 64, color: colors.textMuted),
          const Gap16(),
          Text(
            context.l10n.raffleNoEligibleParticipants,
            textAlign: TextAlign.center,
            style: typography.headingH3.copyWith(color: colors.textDefault),
          ),
          const Spacer(),
          AppButton.secondary(
            label: context.l10n.back,
            onPressed: () => Navigator.of(context).pop(),
          ),
          const Gap16(),
        ],
      ),
    );
  }
}
