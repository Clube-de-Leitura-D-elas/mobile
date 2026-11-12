import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:mobile/features/raffles/domain/entities/raffle_failure.dart';
import 'package:mobile/features/raffles/presentation/raffle_failure_message.dart';

/// Erro do sorteio em tela cheia: motivo, "Tentar novamente" quando adianta
/// e "Sair" quando a sessão expirou.
class RaffleErrorState extends StatelessWidget {
  const RaffleErrorState({
    super.key,
    required this.failure,
    required this.onRetry,
  });

  final RaffleFailure failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final canRetry = raffleFailureIsRetryable(failure);
    final hint = canRetry ? raffleRetryHint(l10n, failure) : null;
    final reason = raffleFailureMessage(l10n, failure);
    final sessionExpired = failure is RaffleSessionExpiredFailure;

    return AppErrorState(
      message: hint == null ? reason : '$reason $hint',
      onRetry: canRetry ? onRetry : null,
      secondaryLabel: sessionExpired ? l10n.logoutTooltip : null,
      onSecondary: sessionExpired
          ? () => context.read<SessionCubit>().logOut()
          : null,
    );
  }
}
