import 'package:mobile/core/supabase/supabase_failure.dart';
import 'package:mobile/core/supabase/supabase_response.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class SupabaseService {
  User? get currentUser;
  Stream<AuthState> get authStateChanges;

  Future<Result<SupabaseResponse<T>, SupabaseFailure>> invokeFunction<T>({
    required String functionName,
    Map<String, dynamic>? body,
    T Function(dynamic data)? decoder,
  });

  Future<Result<User, SupabaseFailure>> signInWithIdToken({
    required OAuthProvider provider,
    required String idToken,
    String? accessToken,
  });

  Future<Result<User, SupabaseFailure>> signInWithPassword({
    required String email,
    required String password,
  });

  Future<Result<User, SupabaseFailure>> signUpWithPassword({
    required String email,
    required String password,
  });

  Future<Result<void, SupabaseFailure>> signOut();
}
