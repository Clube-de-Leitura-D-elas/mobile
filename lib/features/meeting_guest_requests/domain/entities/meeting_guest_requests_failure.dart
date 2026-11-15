import 'package:equatable/equatable.dart';

sealed class MeetingGuestRequestsFailure extends Equatable {
  const MeetingGuestRequestsFailure();

  @override
  List<Object?> get props => [];
}

class MeetingGuestRequestsNetworkFailure extends MeetingGuestRequestsFailure {
  const MeetingGuestRequestsNetworkFailure();
}

class MeetingGuestRequestsSessionExpiredFailure
    extends MeetingGuestRequestsFailure {
  const MeetingGuestRequestsSessionExpiredFailure();
}

/// Quem chamou não é a anfitriã do encontro nem coordenadora do grupo
/// (HTTP 403).
class MeetingGuestRequestsNotReviewerFailure
    extends MeetingGuestRequestsFailure {
  const MeetingGuestRequestsNotReviewerFailure();
}

/// Id do encontro ou do pedido que o backend não aceita (HTTP 400).
class MeetingGuestRequestsInvalidFailure extends MeetingGuestRequestsFailure {
  const MeetingGuestRequestsInvalidFailure();
}

/// O pedido não existe, ou quem chamou não decide aquele encontro (HTTP 404).
class GuestRequestNotFoundFailure extends MeetingGuestRequestsFailure {
  const GuestRequestNotFoundFailure();
}

/// Outra pessoa já decidiu o pedido (HTTP 409).
class GuestRequestAlreadyReviewedFailure extends MeetingGuestRequestsFailure {
  const GuestRequestAlreadyReviewedFailure();
}

/// O encontro fechou, a conta da leitora foi inativada ou ela virou membro
/// do grupo depois do pedido (HTTP 409).
class GuestRequestNoLongerValidFailure extends MeetingGuestRequestsFailure {
  const GuestRequestNoLongerValidFailure();
}

class MeetingGuestRequestsServerFailure extends MeetingGuestRequestsFailure {
  const MeetingGuestRequestsServerFailure();
}
