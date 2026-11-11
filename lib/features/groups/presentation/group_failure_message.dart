import 'package:mobile/features/groups/domain/entities/group_failure.dart';
import 'package:mobile/l10n/app_localizations.dart';

/// Texto para a usuária. Rede, sessão e permissão vêm do l10n; as falhas de
/// cada ação trazem o próprio texto.
String groupFailureMessage(AppLocalizations l10n, GroupFailure failure) =>
    switch (failure) {
      GroupNetworkFailure() => l10n.errorNoConnection,
      GroupSessionExpiredFailure() => l10n.errorSessionExpired,
      GroupForbiddenFailure() => l10n.errorForbidden,
      _ => failure.message,
    };
