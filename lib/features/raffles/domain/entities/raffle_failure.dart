import 'package:equatable/equatable.dart';

/// Falhas do sorteio. O texto de cada uma vem do l10n, na apresentação.
abstract class RaffleFailure extends Equatable {
  const RaffleFailure();

  @override
  List<Object?> get props => [];
}

class RaffleServerFailure extends RaffleFailure {
  const RaffleServerFailure();
}

class RaffleNetworkFailure extends RaffleFailure {
  const RaffleNetworkFailure();
}

class RaffleSessionExpiredFailure extends RaffleFailure {
  const RaffleSessionExpiredFailure();
}

/// Só coordenadoras e a anfitriã podem sortear (HTTP 403).
class RaffleForbiddenFailure extends RaffleFailure {
  const RaffleForbiddenFailure();
}

/// O encontro já tem resultado (HTTP 409 `raffle already recorded`).
class RaffleAlreadyRecordedFailure extends RaffleFailure {
  const RaffleAlreadyRecordedFailure();
}

/// O encontro ainda não foi encerrado (HTTP 409).
class RaffleMeetingNotEndedFailure extends RaffleFailure {
  const RaffleMeetingNotEndedFailure();
}

/// A lista enviada não vale mais: é preciso buscá-la de novo antes de
/// sortear outra vez.
abstract class RaffleStaleListFailure extends RaffleFailure {
  const RaffleStaleListFailure();
}

/// Alguma participante enviada não é mais elegível (HTTP 422).
class RaffleParticipantsChangedFailure extends RaffleStaleListFailure {
  const RaffleParticipantsChangedFailure();
}

/// O livro da sorteada já saiu em outro sorteio do grupo (HTTP 409).
class RaffleBookAlreadyDrawnFailure extends RaffleStaleListFailure {
  const RaffleBookAlreadyDrawnFailure();
}

/// A indicação de livro da sorteada não está mais disponível (HTTP 409).
class RaffleBookSuggestionUnavailableFailure extends RaffleStaleListFailure {
  const RaffleBookSuggestionUnavailableFailure();
}
