import 'package:equatable/equatable.dart';

sealed class GroupDiscoveryFailure extends Equatable {
  const GroupDiscoveryFailure();

  @override
  List<Object?> get props => [];
}

class GroupDiscoveryNetworkFailure extends GroupDiscoveryFailure {
  const GroupDiscoveryNetworkFailure();
}

class GroupDiscoverySessionExpiredFailure extends GroupDiscoveryFailure {
  const GroupDiscoverySessionExpiredFailure();
}

/// Conta inativa (HTTP 403): tentar de novo não resolve.
class GroupDiscoveryInactiveAccountFailure extends GroupDiscoveryFailure {
  const GroupDiscoveryInactiveAccountFailure();
}

/// Grupo inexistente, inativo ou de outra cidade.
class GroupUnavailableFailure extends GroupDiscoveryFailure {
  const GroupUnavailableFailure();
}

/// A leitora já pediu entrada ou já é membro: o status na tela está velho.
class GroupJoinAlreadyRequestedFailure extends GroupDiscoveryFailure {
  const GroupJoinAlreadyRequestedFailure();
}

/// O grupo ainda não tem coordenadora para aprovar pedidos.
class GroupJoinNoCoordinatorFailure extends GroupDiscoveryFailure {
  const GroupJoinNoCoordinatorFailure();
}

class GroupDiscoveryServerFailure extends GroupDiscoveryFailure {
  const GroupDiscoveryServerFailure();
}
