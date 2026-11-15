import 'package:equatable/equatable.dart';

sealed class CalendarFailure extends Equatable {
  const CalendarFailure();

  @override
  List<Object?> get props => [];
}

class CalendarNetworkFailure extends CalendarFailure {
  const CalendarNetworkFailure();
}

class CalendarSessionExpiredFailure extends CalendarFailure {
  const CalendarSessionExpiredFailure();
}

/// Conta inativa (HTTP 403): tentar de novo não resolve.
class CalendarForbiddenFailure extends CalendarFailure {
  const CalendarForbiddenFailure();
}

class CalendarLoadFailure extends CalendarFailure {
  const CalendarLoadFailure();
}

// Falhas do pedido de participação num encontro de outro grupo.

/// A leitora já tem pedido em aberto: o status no card está velho.
class CalendarGuestAlreadyRequestedFailure extends CalendarFailure {
  const CalendarGuestAlreadyRequestedFailure();
}

/// A leitora tem vínculo ou pedido de entrada com o grupo (talvez criado
/// depois que o mês carregou).
class CalendarGuestAlreadyMemberFailure extends CalendarFailure {
  const CalendarGuestAlreadyMemberFailure();
}

/// Recusada há menos de 24 h: o backend bloqueia o novo pedido.
class CalendarGuestRecentlyRejectedFailure extends CalendarFailure {
  const CalendarGuestRecentlyRejectedFailure();
}

/// O encontro deixou de estar agendado ou já passou.
class CalendarMeetingNotOpenFailure extends CalendarFailure {
  const CalendarMeetingNotOpenFailure();
}

/// O grupo não tem anfitriã nem coordenadora para analisar o pedido.
class CalendarMeetingNoReviewerFailure extends CalendarFailure {
  const CalendarMeetingNoReviewerFailure();
}

/// HTTP 403 "meeting not available": só o backend anterior ao filtro de
/// cidade recusava encontro de outra cidade.
class CalendarMeetingUnavailableFailure extends CalendarFailure {
  const CalendarMeetingUnavailableFailure();
}

class CalendarMeetingNotFoundFailure extends CalendarFailure {
  const CalendarMeetingNotFoundFailure();
}

class CalendarGuestRequestFailure extends CalendarFailure {
  const CalendarGuestRequestFailure();
}
