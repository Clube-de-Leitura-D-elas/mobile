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

  test('each raffle failure has its own reason', () {
    final reasons = {
      for (final failure in const <RaffleFailure>[
        RaffleServerFailure(),
        RaffleNetworkFailure(),
        RaffleSessionExpiredFailure(),
        RaffleForbiddenFailure(),
        RaffleAlreadyRecordedFailure(),
        RaffleMeetingNotEndedFailure(),
        RaffleParticipantsChangedFailure(),
        RaffleBookAlreadyDrawnFailure(),
        RaffleBookSuggestionUnavailableFailure(),
      ])
        failure: raffleFailureMessage(l10n, failure),
    };

    expect(reasons.values.toSet(), hasLength(reasons.length));
    expect(
      reasons[const RaffleBookSuggestionUnavailableFailure()],
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
