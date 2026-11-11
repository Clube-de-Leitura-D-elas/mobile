import 'package:equatable/equatable.dart';

/// Falhas de conta e perfil. O texto de cada uma vem do l10n, na apresentação.
sealed class UserFailure extends Equatable {
  const UserFailure();

  @override
  List<Object?> get props => [];
}

class UserNetworkFailure extends UserFailure {
  const UserNetworkFailure();
}

class UserSessionExpiredFailure extends UserFailure {
  const UserSessionExpiredFailure();
}

class InvalidCredentialsFailure extends UserFailure {
  const InvalidCredentialsFailure();
}

class EmailNotConfirmedFailure extends UserFailure {
  const EmailNotConfirmedFailure();
}

class EmailAlreadyRegisteredFailure extends UserFailure {
  const EmailAlreadyRegisteredFailure();
}

class WeakPasswordFailure extends UserFailure {
  const WeakPasswordFailure();
}

class TooManyAttemptsFailure extends UserFailure {
  const TooManyAttemptsFailure();
}

/// A usuária fechou o seletor de contas do Google: não é erro para mostrar.
class GoogleSignInCanceledFailure extends UserFailure {
  const GoogleSignInCanceledFailure();
}

class GoogleSignInUnavailableFailure extends UserFailure {
  const GoogleSignInUnavailableFailure();
}

class ClaimTokenInvalidFailure extends UserFailure {
  const ClaimTokenInvalidFailure();
}

class UnknownUserFailure extends UserFailure {
  const UnknownUserFailure();
}
