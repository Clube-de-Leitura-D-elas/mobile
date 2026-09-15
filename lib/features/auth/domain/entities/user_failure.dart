import 'package:equatable/equatable.dart';

class UserFailure extends Equatable {
  final String message;

  const UserFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

class UnknownUserFailure extends UserFailure {
  const UnknownUserFailure({required super.message});
}

class MissingGoogleIdTokenFailure extends UserFailure {
  const MissingGoogleIdTokenFailure({required super.message});
}
