import 'package:flutter/foundation.dart';
import 'package:mobile/core/supabase/supabase_failure.dart';
import 'package:mobile/features/auth/domain/entities/user_failure.dart';

/// Falha de login/cadastro no Supabase Auth.
UserFailure userFailureFromAuth(SupabaseFailure failure) {
  debugPrint('[UserFailure] auth: ${failure.message} (${failure.code})');
  final errorCode = failure is AuthSupabaseFailure ? failure.errorCode : null;
  final mapped = switch (errorCode) {
    'invalid_credentials' => const InvalidCredentialsFailure(),
    'email_not_confirmed' => const EmailNotConfirmedFailure(),
    'user_already_exists' || 'email_exists' => const EmailAlreadyRegisteredFailure(),
    'weak_password' => const WeakPasswordFailure(),
    'over_request_rate_limit' ||
    'over_email_send_rate_limit' => const TooManyAttemptsFailure(),
    _ => null,
  };
  if (mapped != null) return mapped;

  // Servidores do Auth sem `error_code` só mandam o texto.
  final message = failure.message.toLowerCase();
  if (message.contains('invalid login credentials')) {
    return const InvalidCredentialsFailure();
  }
  if (message.contains('email not confirmed')) {
    return const EmailNotConfirmedFailure();
  }
  if (message.contains('already registered')) {
    return const EmailAlreadyRegisteredFailure();
  }

  if (failure.kind == SupabaseFailureKind.network) {
    return const UserNetworkFailure();
  }
  return const UnknownUserFailure();
}

/// Falha de uma Edge Function chamada com a sessão da usuária.
UserFailure userFailureFromFunction(
  SupabaseFailure failure, {
  UserFailure fallback = const UnknownUserFailure(),
}) {
  debugPrint('[UserFailure] function: ${failure.message} (${failure.code})');
  return switch (failure.kind) {
    SupabaseFailureKind.network => const UserNetworkFailure(),
    SupabaseFailureKind.unauthorized => const UserSessionExpiredFailure(),
    _ => fallback,
  };
}
