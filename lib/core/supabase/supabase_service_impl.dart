import 'package:flutter/foundation.dart';
import 'package:mobile/core/supabase/supabase_failure.dart';
import 'package:mobile/core/supabase/supabase_response.dart';
import 'package:mobile/core/supabase/supabase_service.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseServiceImpl implements SupabaseService {
  final SupabaseClient _client;

  SupabaseServiceImpl(this._client);

  @override
  User? get currentUser => _client.auth.currentUser;

  @override
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  @override
  Future<Result<SupabaseResponse<T>, SupabaseFailure>> invokeFunction<T>({
    required String functionName,
    Map<String, dynamic>? body,
    T Function(dynamic data)? decoder,
  }) async {
    try {
      debugPrint('[SupabaseService] Invoking function "$functionName" with body: $body');
      final res = await _client.functions.invoke(
        functionName,
        body: body,
      );

      debugPrint('[SupabaseService] Function "$functionName" status: ${res.status}, data: ${res.data}');

      if (res.status >= 400) {
        final message = res.data is Map && res.data['error'] != null
            ? res.data['error'].toString()
            : 'Erro ao executar a função $functionName';
        return Failure(
          FunctionSupabaseFailure(
            message: message,
            code: res.status.toString(),
            details: res.data,
          ),
        );
      }

      T? decodedData;
      if (res.data != null && decoder != null) {
        decodedData = decoder(res.data);
      } else if (res.data is T) {
        decodedData = res.data as T;
      }

      return Success(
        SupabaseResponse<T>(
          data: decodedData,
          statusCode: res.status,
        ),
      );
    } on FunctionException catch (e) {
      debugPrint('[SupabaseService] FunctionException in "$functionName": $e');
      final message = e.details is Map && (e.details as Map)['error'] != null
          ? (e.details as Map)['error'].toString()
          : e.toString();
      return Failure(
        FunctionSupabaseFailure(
          message: message,
          code: e.status.toString(),
          details: e.details,
        ),
      );
    } catch (e) {
      debugPrint('[SupabaseService] Unknown error in "$functionName": $e');
      return Failure(
        UnknownSupabaseFailure(
          message: 'Erro inesperado ao chamar a função $functionName: $e',
        ),
      );
    }
  }

  @override
  Future<Result<User, SupabaseFailure>> signInWithIdToken({
    required OAuthProvider provider,
    required String idToken,
    String? accessToken,
  }) async {
    try {
      debugPrint('[SupabaseService] Signing in with ID token');
      final response = await _client.auth.signInWithIdToken(
        provider: provider,
        idToken: idToken,
        accessToken: accessToken,
      );

      final user = response.user;
      if (user == null) {
        return const Failure(
          AuthSupabaseFailure(message: 'Usuário nulo após autenticação'),
        );
      }

      return Success(user);
    } on AuthException catch (e) {
      debugPrint('[SupabaseService] AuthException during sign in: ${e.message}');
      return Failure(
        AuthSupabaseFailure(
          message: e.message,
          code: e.statusCode,
        ),
      );
    } catch (e) {
      debugPrint('[SupabaseService] Unexpected error during sign in: $e');
      return Failure(
        UnknownSupabaseFailure(
          message: 'Erro inesperado ao realizar login: $e',
        ),
      );
    }
  }

  @override
  Future<Result<User, SupabaseFailure>> signInWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('[SupabaseService] Signing in with password for email: $email');
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        return const Failure(
          AuthSupabaseFailure(message: 'Usuário nulo após autenticação'),
        );
      }

      return Success(user);
    } on AuthException catch (e) {
      debugPrint('[SupabaseService] AuthException during password sign in: ${e.message}');
      return Failure(
        AuthSupabaseFailure(
          message: e.message,
          code: e.statusCode,
        ),
      );
    } catch (e) {
      debugPrint('[SupabaseService] Unexpected error during password sign in: $e');
      return Failure(
        UnknownSupabaseFailure(
          message: 'Erro inesperado ao realizar login com e-mail: $e',
        ),
      );
    }
  }

  @override
  Future<Result<User, SupabaseFailure>> signUpWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('[SupabaseService] Signing up with password for email: $email');
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        return const Failure(
          AuthSupabaseFailure(message: 'Usuário nulo após registro'),
        );
      }

      return Success(user);
    } on AuthException catch (e) {
      debugPrint('[SupabaseService] AuthException during sign up: ${e.message}');
      return Failure(
        AuthSupabaseFailure(
          message: e.message,
          code: e.statusCode,
        ),
      );
    } catch (e) {
      debugPrint('[SupabaseService] Unexpected error during sign up: $e');
      return Failure(
        UnknownSupabaseFailure(
          message: 'Erro inesperado ao realizar registro: $e',
        ),
      );
    }
  }

  @override
  Future<Result<void, SupabaseFailure>> signOut() async {
    try {
      debugPrint('[SupabaseService] Signing out user');
      await _client.auth.signOut();
      return const Success(null);
    } catch (e) {
      debugPrint('[SupabaseService] Error signing out: $e');
      return Failure(
        UnknownSupabaseFailure(message: 'Erro ao realizar logout: $e'),
      );
    }
  }
}
