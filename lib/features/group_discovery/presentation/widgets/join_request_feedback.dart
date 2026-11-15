import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/group_discovery/domain/entities/group_discovery_failure.dart';
import 'package:mobile/l10n/app_localizations.dart';

/// Aviso do resultado de um pedido de entrada; [failure] `null` é sucesso.
void showJoinRequestFeedback(
  BuildContext context, {
  GroupDiscoveryFailure? failure,
}) {
  final l10n = context.l10n;
  if (failure == null) {
    AppToast.show(
      context,
      message: l10n.publicGroupJoinSuccess,
      type: AppToastType.success,
    );
    return;
  }
  AppToast.show(
    context,
    message: joinFailureMessage(l10n, failure),
    type: failure is GroupJoinAlreadyRequestedFailure
        ? AppToastType.info
        : AppToastType.error,
  );
}

String joinFailureMessage(
  AppLocalizations l10n,
  GroupDiscoveryFailure failure,
) => switch (failure) {
  GroupDiscoveryNetworkFailure() => l10n.errorNoConnection,
  GroupDiscoverySessionExpiredFailure() => l10n.errorSessionExpired,
  GroupDiscoveryInactiveAccountFailure() => l10n.errorForbidden,
  GroupJoinAlreadyRequestedFailure() => l10n.publicGroupJoinAlreadyRequested,
  GroupJoinNoCoordinatorFailure() => l10n.publicGroupJoinNoCoordinator,
  // Só a lista chega aqui: a tela do grupo troca para o estado indisponível.
  GroupUnavailableFailure() => l10n.publicGroupUnavailable,
  GroupDiscoveryServerFailure() => l10n.publicGroupJoinError,
};
