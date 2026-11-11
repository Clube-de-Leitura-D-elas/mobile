import 'package:mobile/features/raffles/domain/entities/raffle_failure.dart';
import 'package:mobile/l10n/app_localizations.dart';

/// Texto da falha do sorteio. Os textos de 409 e 422 mandam tocar em
/// "Tentar novamente": use [hasRetry] `false` onde não há esse botão.
String raffleFailureMessage(
  AppLocalizations l10n,
  RaffleFailure failure, {
  bool hasRetry = true,
}) => switch (failure) {
  RaffleNetworkFailure() => l10n.errorNoConnection,
  RaffleSessionExpiredFailure() => l10n.errorSessionExpired,
  RaffleAlreadyRecordedFailure() when hasRetry =>
    l10n.raffleAlreadyRecordedError,
  RaffleParticipantsChangedFailure() when hasRetry =>
    l10n.raffleParticipantsChangedError,
  _ => l10n.raffleErrorMessage,
};
