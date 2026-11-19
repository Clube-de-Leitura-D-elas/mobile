import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/raffles/presentation/widgets/raffle_error_state.dart';
import 'package:mobile/features/raffles/presentation/cubit/raffle_execution_cubit.dart';
import 'package:mobile/features/raffles/presentation/cubit/raffle_execution_state.dart';
import 'package:mobile/features/raffles/presentation/pages/raffle_result_screen.dart';
import 'package:mobile/features/raffles/presentation/widgets/raffle_draw_reel.dart';
import 'package:mobile/features/raffles/domain/entities/raffle_participant.dart';
import 'package:mobile/features/raffles/domain/entities/raffle_result.dart';

class RaffleExecutionScreen extends StatefulWidget {
  final String meetingId;
  final String meetingTitle;

  const RaffleExecutionScreen({
    super.key,
    required this.meetingId,
    this.meetingTitle = '',
  });

  @override
  State<RaffleExecutionScreen> createState() => _RaffleExecutionScreenState();
}

class _RaffleExecutionScreenState extends State<RaffleExecutionScreen> {
  /// Indicações girando na roleta; nulo quando não há sorteio em andamento.
  List<RaffleParticipant>? _reelPool;

  /// Resultado na tela quando o "Sortear novamente" foi tocado. Enquanto o
  /// estado ainda mostra esse resultado, o novo sorteio não voltou.
  RaffleResult? _resultBeforeDraw;

  void _startReel(List<RaffleParticipant> pool, {RaffleResult? previous}) {
    setState(() {
      _reelPool = pool;
      _resultBeforeDraw = previous;
    });
  }

  void _stopReel() {
    if (_reelPool == null) return;
    setState(() {
      _reelPool = null;
      _resultBeforeDraw = null;
    });
  }

  /// Vencedora a revelar, `''` enquanto o servidor sorteia, ou nulo quando a
  /// roleta não deve aparecer neste estado.
  String? _reelWinnerFor(RaffleExecutionState state) {
    if (_reelPool == null) return null;
    if (state is RaffleExecutionReady && state.isDrawing) return '';
    if (state is RaffleExecutionResultLoaded && !state.isPersisted) {
      return state.result == _resultBeforeDraw ? '' : state.result.winnerId;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocConsumer<RaffleExecutionCubit, RaffleExecutionState>(
      listener: (context, state) {
        if (state is RaffleExecutionReady && state.isDrawing) {
          _startReel(state.eligibleParticipants);
        } else if (state is RaffleExecutionError ||
            state is RaffleExecutionNoEligible) {
          _stopReel();
        }
        if (state is RaffleExecutionSuccess) {
          context.showAppToast(context.l10n.raffleSavedSuccessToast);
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        final reelWinner = _reelWinnerFor(state);
        final pool = _reelPool;
        final Widget body;

        if (reelWinner != null && pool != null && pool.isNotEmpty) {
          body = RaffleDrawReel(
            key: ValueKey(_resultBeforeDraw),
            participants: pool,
            winnerId: reelWinner.isEmpty ? null : reelWinner,
            onRevealed: _stopReel,
          );
        } else if (state is RaffleExecutionLoading) {
          body = Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(colors.actionPrimary),
            ),
          );
        } else if (state is RaffleExecutionResultLoaded) {
          body = RaffleResultScreen(
            result: state.result,
            isPersisted: state.isPersisted,
            isSubmitting: state.isSubmitting,
            canDrawAgain: state.eligibleParticipants.isNotEmpty,
            onDrawAgain: () {
              _startReel(state.eligibleParticipants, previous: state.result);
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
        } else if (state is RaffleExecutionNoEligible) {
          body = _NoEligibleView(
            meetingTitle: state.meetingTitle.isNotEmpty
                ? state.meetingTitle
                : widget.meetingTitle,
          );
        } else if (state is RaffleExecutionReady) {
          body = _ReadyDrawView(
            state: state,
            onDraw: () => context.read<RaffleExecutionCubit>().draw(),
          );
        } else if (state is RaffleExecutionError) {
          body = RaffleErrorState(
            failure: state.failure,
            onRetry: () => context.read<RaffleExecutionCubit>().retry(),
          );
        } else {
          body = const SizedBox.shrink();
        }

        final showsResult =
            reelWinner == null && state is RaffleExecutionResultLoaded;

        return Scaffold(
          backgroundColor: colors.bgDefault,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: ScreenHeader.back(
              title: showsResult
                  ? context.l10n.raffleResultTitle
                  : context.l10n.raffleDrawScreenTitle,
            ),
          ),
          body: SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              layoutBuilder: _outgoingInert,
              child: KeyedSubtree(
                key: ValueKey(reelWinner != null ? 'reel' : state.runtimeType),
                child: body,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// A tela que está saindo não pode receber toque nem seguir girando: um
/// "Concluir" ali salvaria a vencedora anterior.
Widget _outgoingInert(Widget? current, List<Widget> previous) {
  return Stack(
    alignment: Alignment.center,
    children: [
      for (final child in previous)
        IgnorePointer(child: TickerMode(enabled: false, child: child)),
      ?current,
    ],
  );
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
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: RaffleCoverFan(participants: state.eligibleParticipants),
              ),
            ),
          ),
          Text(
            context.l10n.raffleDisclaimer,
            textAlign: TextAlign.center,
            style: typography.bodySmall.copyWith(
              color: colors.textMuted,
              height: 1.4,
            ),
          ),
          const Gap16(),
          AppButton.primary(
            label: context.l10n.raffleDrawButton,
            size: AppButtonSize.lg,
            isLoading: state.isDrawing,
            onPressed: () {
              HapticFeedback.mediumImpact();
              onDraw();
            },
          ),
          const Gap16(),
        ],
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
