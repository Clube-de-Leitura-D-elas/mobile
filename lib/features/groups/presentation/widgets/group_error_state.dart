import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:mobile/features/groups/domain/entities/group_failure.dart';
import 'package:mobile/features/groups/presentation/group_failure_message.dart';

/// Falhas em que tentar de novo dá o mesmo resultado.
bool groupFailureIsRetryable(GroupFailure failure) =>
    failure is! GroupNotFoundFailure &&
    failure is! MeetingNotFoundFailure &&
    failure is! GroupForbiddenFailure;

/// Erro de grupo ou encontro em tela cheia: motivo, "Tentar novamente"
/// quando adianta e "Sair" quando a sessão expirou.
class GroupErrorState extends StatelessWidget {
  const GroupErrorState({
    super.key,
    required this.failure,
    required this.onRetry,
  });

  final GroupFailure failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final sessionExpired = failure is GroupSessionExpiredFailure;

    return AppErrorState(
      message: groupFailureMessage(context.l10n, failure),
      onRetry: groupFailureIsRetryable(failure) ? onRetry : null,
      secondaryLabel: sessionExpired ? context.l10n.logoutTooltip : null,
      onSecondary: sessionExpired
          ? () => context.read<SessionCubit>().logOut()
          : null,
    );
  }
}
