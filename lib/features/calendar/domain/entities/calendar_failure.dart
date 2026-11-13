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
