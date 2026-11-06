import 'package:equatable/equatable.dart';

sealed class NotificationFailure extends Equatable {
  const NotificationFailure();

  @override
  List<Object?> get props => [];
}

class NotificationsLoadFailure extends NotificationFailure {
  const NotificationsLoadFailure();
}

class NotificationMarkReadFailure extends NotificationFailure {
  const NotificationMarkReadFailure();
}
