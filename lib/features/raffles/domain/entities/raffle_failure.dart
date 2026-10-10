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
