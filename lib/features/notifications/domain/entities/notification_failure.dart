import 'package:equatable/equatable.dart';

class NotificationFailure extends Equatable {
  final String message;

  const NotificationFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
