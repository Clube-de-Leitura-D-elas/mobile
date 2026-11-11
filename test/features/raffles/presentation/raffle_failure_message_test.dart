import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/raffles/domain/entities/raffle_failure.dart';
import 'package:mobile/features/raffles/presentation/raffle_failure_message.dart';
import 'package:mobile/l10n/app_localizations.dart';

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('pt', 'BR'));
  });

  test('each raffle failure maps to its own reason', () {
    final expected = <RaffleFailure, String>{
      const RaffleServerFailure(): l10n.raffleErrorMessage,
      const RaffleNetworkFailure(): l10n.errorNoConnection,
      const RaffleSessionExpiredFailure(): l10n.errorSessionExpired,
      const RaffleForbiddenFailure(): l10n.errorForbidden,
      const RaffleAlreadyRecordedFailure(): l10n.raffleAlreadyRecordedError,
      const RaffleMeetingNotEndedFailure(): l10n.raffleMeetingNotEndedError,
      const RaffleParticipantsChangedFailure():
          l10n.raffleParticipantsChangedError,
      const RaffleBookAlreadyDrawnFailure(): l10n.raffleBookAlreadyDrawnError,
      const RaffleBookSuggestionUnavailableFailure():
          l10n.raffleBookSuggestionUnavailableError,
    };

    for (final MapEntry(key: failure, value: message) in expected.entries) {
      expect(
        raffleFailureMessage(l10n, failure),
        message,
        reason: '${failure.runtimeType}',
      );
    }
    expect(expected.values.toSet(), hasLength(expected.length));
    expect(
      raffleFailureMessage(
        l10n,
        const RaffleBookSuggestionUnavailableFailure(),
      ),
      'A indicação de livro de uma participante não está mais disponível.',
    );
  });

  test('retry hints only where retry changes the outcome', () {
    expect(
      raffleRetryHint(l10n, const RaffleAlreadyRecordedFailure()),
      'Toque em Tentar novamente para ver o resultado.',
    );
    expect(
      raffleRetryHint(l10n, const RaffleBookAlreadyDrawnFailure()),
      'Toque em Tentar novamente para atualizar a lista.',
    );
    expect(raffleRetryHint(l10n, const RaffleNetworkFailure()), isNull);
  });
}
