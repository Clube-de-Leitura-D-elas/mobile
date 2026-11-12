import 'package:mobile/features/raffles/domain/entities/raffle_failure.dart';
import 'package:mobile/l10n/app_localizations.dart';

/// Motivo da falha do sorteio, sem instrução de "Tentar novamente".
String raffleFailureMessage(AppLocalizations l10n, RaffleFailure failure) =>
    switch (failure) {
      RaffleNetworkFailure() => l10n.errorNoConnection,
      RaffleSessionExpiredFailure() => l10n.errorSessionExpired,
      RaffleForbiddenFailure() => l10n.errorForbidden,
      RaffleAlreadyRecordedFailure() => l10n.raffleAlreadyRecordedError,
      RaffleMeetingNotEndedFailure() => l10n.raffleMeetingNotEndedError,
      RaffleParticipantsChangedFailure() => l10n.raffleParticipantsChangedError,
      RaffleBookAlreadyDrawnFailure() => l10n.raffleBookAlreadyDrawnError,
      RaffleBookSuggestionUnavailableFailure() =>
        l10n.raffleBookSuggestionUnavailableError,
      _ => l10n.raffleErrorMessage,
    };

/// O que "Tentar novamente" faz depois desta falha, para juntar ao motivo
/// onde há o botão. Nulo quando o botão só repete a ação.
String? raffleRetryHint(AppLocalizations l10n, RaffleFailure failure) =>
    switch (failure) {
      RaffleAlreadyRecordedFailure() => l10n.raffleRetryShowResultHint,
      RaffleStaleListFailure() => l10n.raffleRetryRefreshListHint,
      _ => null,
    };

/// Falhas em que tentar de novo dá o mesmo resultado.
bool raffleFailureIsRetryable(RaffleFailure failure) =>
    failure is! RaffleForbiddenFailure &&
    failure is! RaffleMeetingNotEndedFailure;
