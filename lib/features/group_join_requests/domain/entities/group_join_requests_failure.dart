import 'package:equatable/equatable.dart';

sealed class GroupJoinRequestsFailure extends Equatable {
  const GroupJoinRequestsFailure();

  @override
  List<Object?> get props => [];
}

class GroupJoinRequestsNetworkFailure extends GroupJoinRequestsFailure {
  const GroupJoinRequestsNetworkFailure();
}

class GroupJoinRequestsSessionExpiredFailure extends GroupJoinRequestsFailure {
  const GroupJoinRequestsSessionExpiredFailure();
}

/// Quem chamou não é coordenadora ativa do grupo (HTTP 403).
class GroupJoinRequestsNotCoordinatorFailure extends GroupJoinRequestsFailure {
  const GroupJoinRequestsNotCoordinatorFailure();
}

/// Id do grupo ou do pedido que o backend não aceita (HTTP 400).
class GroupJoinRequestsInvalidFailure extends GroupJoinRequestsFailure {
  const GroupJoinRequestsInvalidFailure();
}

/// O pedido não existe, ou quem chamou não coordena aquele grupo (HTTP 404).
class JoinRequestNotFoundFailure extends GroupJoinRequestsFailure {
  const JoinRequestNotFoundFailure();
}

/// Outra coordenadora já decidiu o pedido (HTTP 409).
class JoinRequestAlreadyReviewedFailure extends GroupJoinRequestsFailure {
  const JoinRequestAlreadyReviewedFailure();
}

/// O grupo ou a conta da leitora foi inativado depois do pedido (HTTP 409).
class JoinRequestNoLongerValidFailure extends GroupJoinRequestsFailure {
  const JoinRequestNoLongerValidFailure();
}

class GroupJoinRequestsServerFailure extends GroupJoinRequestsFailure {
  const GroupJoinRequestsServerFailure();
}
