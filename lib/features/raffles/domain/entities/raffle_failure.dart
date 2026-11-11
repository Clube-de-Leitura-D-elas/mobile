import 'package:equatable/equatable.dart';

abstract class RaffleFailure extends Equatable {
  final String message;
  const RaffleFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class RaffleServerFailure extends RaffleFailure {
  const RaffleServerFailure([
    super.message = 'Erro ao processar sorteio no servidor.',
  ]);
}

class RaffleNetworkFailure extends RaffleFailure {
  const RaffleNetworkFailure([super.message = 'Sem conexão com a internet.']);
}

class RaffleSessionExpiredFailure extends RaffleFailure {
  const RaffleSessionExpiredFailure([
    super.message =
        'Sua sessão expirou. Saia do app e entre de novo na sua conta.',
  ]);
}

/// O encontro já tem resultado (HTTP 409 `raffle already recorded`).
class RaffleAlreadyRecordedFailure extends RaffleFailure {
  const RaffleAlreadyRecordedFailure([
    super.message = 'O sorteio deste encontro já foi feito.',
  ]);
}

/// Alguma participante enviada não é mais elegível (HTTP 422).
class RaffleParticipantsChangedFailure extends RaffleFailure {
  const RaffleParticipantsChangedFailure([
    super.message = 'A lista de participantes mudou.',
  ]);
}
