import 'package:mobile/features/auth/domain/entities/user_failure.dart';
import 'package:mobile/l10n/app_localizations.dart';

/// Falhas em que tentar de novo dá o mesmo resultado.
bool userFailureIsRetryable(UserFailure failure) =>
    failure is! UserForbiddenFailure;

/// Texto para a usuária. [fallback] é a mensagem da ação que falhou
/// ("Não foi possível entrar...") quando a causa não tem texto próprio.
String userFailureMessage(
  AppLocalizations l10n,
  UserFailure failure, {
  required String fallback,
}) => switch (failure) {
  UserNetworkFailure() => l10n.errorNoConnection,
  UserSessionExpiredFailure() => l10n.errorSessionExpired,
  UserForbiddenFailure() => l10n.errorForbidden,
  InvalidCredentialsFailure() => l10n.authInvalidCredentialsError,
  EmailNotConfirmedFailure() => l10n.confirmEmailBeforeLoginError,
  EmailAlreadyRegisteredFailure() => l10n.authEmailAlreadyRegisteredError,
  WeakPasswordFailure() => l10n.authWeakPasswordError,
  TooManyAttemptsFailure() => l10n.authTooManyAttemptsError,
  GoogleSignInUnavailableFailure() => l10n.authGoogleUnavailableError,
  ClaimTokenInvalidFailure() => l10n.claimTokenInvalidError,
  GoogleSignInCanceledFailure() || UnknownUserFailure() => fallback,
};
