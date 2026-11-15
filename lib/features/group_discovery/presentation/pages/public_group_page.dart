import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:mobile/features/group_discovery/domain/entities/discovery_group_entity.dart';
import 'package:mobile/features/group_discovery/domain/entities/group_discovery_failure.dart';
import 'package:mobile/features/group_discovery/presentation/cubit/public_group_cubit.dart';
import 'package:mobile/features/group_discovery/presentation/cubit/public_group_state.dart';
import 'package:mobile/features/group_discovery/presentation/widgets/join_request_dialog.dart';
import 'package:mobile/features/group_discovery/presentation/widgets/join_request_feedback.dart';
import 'package:mobile/features/group_discovery/presentation/widgets/public_group_content.dart';
import 'package:mobile/features/groups/presentation/routes/group_route_paths.dart';

class PublicGroupPage extends StatelessWidget {
  const PublicGroupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PublicGroupCubit, PublicGroupState>(
      listenWhen: (previous, current) =>
          !previous.hasJoinFeedback && current.hasJoinFeedback,
      listener: _showJoinFeedback,
      builder: (context, state) {
        final group = state.group;
        if (state.status == PublicGroupStatus.loaded && group != null) {
          return Scaffold(
            backgroundColor: context.colors.bgDefault,
            body: PublicGroupContent(
              group: group,
              isRequesting: state.isRequesting,
              onRequestJoin: () => _confirmJoin(context, group),
              // Quem já é membro troca esta tela pela de membro.
              onOpenMemberDetails: () => context.pushReplacement(
                Uri(
                  path: GroupRoutePaths.groupDetails,
                  queryParameters: {'group_id': group.id},
                ).toString(),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: context.colors.bgDefault,
          appBar: ScreenHeader.back(title: context.l10n.publicGroupTitle),
          body: _PublicGroupMessage(state: state),
        );
      },
    );
  }

  Future<void> _confirmJoin(
    BuildContext context,
    DiscoveryGroupEntity group,
  ) async {
    final cubit = context.read<PublicGroupCubit>();
    final confirmed = await JoinRequestDialog.show(
      context,
      groupNumber: group.number,
    );
    if (confirmed == true) await cubit.requestJoin();
  }

  void _showJoinFeedback(BuildContext context, PublicGroupState state) {
    showJoinRequestFeedback(context, failure: state.joinFailure);
    context.read<PublicGroupCubit>().clearJoinFeedback();
  }
}

/// Carregando, erro ou grupo indisponível.
class _PublicGroupMessage extends StatelessWidget {
  final PublicGroupState state;

  const _PublicGroupMessage({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<PublicGroupCubit>();
    final failure = state.failure;

    return switch (state.status) {
      PublicGroupStatus.unavailable => AppErrorState(
        message: l10n.publicGroupUnavailable,
      ),
      PublicGroupStatus.error => AppErrorState(
        message: switch (failure) {
          GroupDiscoveryNetworkFailure() => l10n.errorNoConnection,
          GroupDiscoverySessionExpiredFailure() => l10n.errorSessionExpired,
          GroupDiscoveryInactiveAccountFailure() => l10n.errorForbidden,
          _ => l10n.publicGroupLoadError,
        },
        onRetry: failure is GroupDiscoveryInactiveAccountFailure
            ? null
            : cubit.retry,
        secondaryLabel: failure is GroupDiscoverySessionExpiredFailure
            ? l10n.logoutTooltip
            : null,
        onSecondary: () => context.read<SessionCubit>().logOut(),
      ),
      _ => Center(
        child: Semantics(
          label: l10n.publicGroupLoading,
          child: CircularProgressIndicator(color: context.colors.actionPrimary),
        ),
      ),
    };
  }
}
