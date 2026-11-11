import 'package:equatable/equatable.dart';

sealed class NotificationFailure extends Equatable {
  const NotificationFailure();

  @override
  List<Object?> get props => [];
}

class NotificationNetworkFailure extends NotificationFailure {
  const NotificationNetworkFailure();
}

class NotificationSessionExpiredFailure extends NotificationFailure {
  const NotificationSessionExpiredFailure();
}

class NotificationsLoadFailure extends NotificationFailure {
  const NotificationsLoadFailure();
}

class NotificationMarkReadFailure extends NotificationFailure {
  const NotificationMarkReadFailure();
}
