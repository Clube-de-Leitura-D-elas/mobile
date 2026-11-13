import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/group_join_requests/presentation/cubit/group_join_requests_cubit.dart';
import 'package:mobile/features/group_join_requests/presentation/cubit/group_join_requests_state.dart';

/// Acesso aos pedidos de entrada no detalhe do grupo. Só aparece para a
/// coordenadora; para as outras leitoras, e se a consulta falhar, não ocupa
/// espaço.
class JoinRequestsAccessButton extends StatelessWidget {
  final VoidCallback onPressed;

  const JoinRequestsAccessButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupJoinRequestsCubit, GroupJoinRequestsState>(
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.requests.length != current.requests.length,
      builder: (context, state) {
        if (state.status != GroupJoinRequestsStatus.loaded) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: EdgeInsets.only(top: context.spacing.s16),
          child: AppButton.secondary(
            label: context.l10n.groupJoinRequestsAccess(state.requests.length),
            size: AppButtonSize.lg,
            onPressed: onPressed,
          ),
        );
      },
    );
  }
}
