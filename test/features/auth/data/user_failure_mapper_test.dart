import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/supabase/supabase_failure.dart';
import 'package:mobile/features/auth/data/user_failure_mapper.dart';
import 'package:mobile/features/auth/domain/entities/user_failure.dart';

void main() {
  group('userFailureFromAuth', () {
    final byCode = <String, UserFailure>{
      'invalid_credentials': const InvalidCredentialsFailure(),
      'email_not_confirmed': const EmailNotConfirmedFailure(),
      'user_already_exists': const EmailAlreadyRegisteredFailure(),
      'email_exists': const EmailAlreadyRegisteredFailure(),
      'weak_password': const WeakPasswordFailure(),
      'over_request_rate_limit': const TooManyAttemptsFailure(),
      'over_email_send_rate_limit': const TooManyAttemptsFailure(),
    };
    for (final MapEntry(key: code, value: expected) in byCode.entries) {
      test('maps error code $code', () {
        final failure = userFailureFromAuth(
          AuthSupabaseFailure(message: 'raw', code: '400', errorCode: code),
        );

        expect(failure, expected);
      });
    }

    final byMessage = <String, UserFailure>{
      'Invalid login credentials': const InvalidCredentialsFailure(),
      'Email not confirmed': const EmailNotConfirmedFailure(),
      'User already registered': const EmailAlreadyRegisteredFailure(),
    };
    for (final MapEntry(key: message, value: expected) in byMessage.entries) {
      test('falls back to the message "$message" without error code', () {
        expect(
          userFailureFromAuth(AuthSupabaseFailure(message: message)),
          expected,
        );
      });
    }

    test('maps a network failure', () {
      expect(
        userFailureFromAuth(
          const AuthSupabaseFailure(
            message: 'AuthRetryableFetchException',
            kind: SupabaseFailureKind.network,
          ),
        ),
        const UserNetworkFailure(),
      );
    });

    test('anything else is unknown', () {
      expect(
        userFailureFromAuth(
          const UnknownSupabaseFailure(message: 'Erro inesperado: boom'),
        ),
        const UnknownUserFailure(),
      );
    });
  });

  group('userFailureFromFunction', () {
    test('maps network and expired session', () {
      expect(
        userFailureFromFunction(
          const FunctionSupabaseFailure(
            message: 'x',
            kind: SupabaseFailureKind.network,
          ),
        ),
        const UserNetworkFailure(),
      );
      expect(
        userFailureFromFunction(
          const FunctionSupabaseFailure(
            message: 'Unauthorized',
            kind: SupabaseFailureKind.unauthorized,
          ),
        ),
        const UserSessionExpiredFailure(),
      );
    });

    test('uses the fallback for other kinds', () {
      expect(
        userFailureFromFunction(
          const FunctionSupabaseFailure(
            message: 'Unable to load profile',
            kind: SupabaseFailureKind.server,
          ),
        ),
        const UnknownUserFailure(),
      );
    });
  });
}
