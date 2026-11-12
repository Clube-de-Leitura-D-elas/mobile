import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mobile/core/supabase/supabase_failure.dart';
import 'package:mobile/core/supabase/supabase_service.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/auth/data/models/user_model.dart';
import 'package:mobile/features/auth/data/models/user_profile_model.dart';
import 'package:mobile/features/auth/data/user_failure_mapper.dart';
import 'package:mobile/features/auth/domain/entities/user_entity.dart';
import 'package:mobile/features/auth/domain/entities/user_failure.dart';
import 'package:mobile/features/auth/domain/entities/user_profile_entity.dart';
import 'package:mobile/features/auth/domain/repository/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseService supabaseService;
  final GoogleSignIn googleSignInClient;

  AuthRepositoryImpl({
    required this.supabaseService,
    required this.googleSignInClient,
  });

  @override
  Future<Result<UserEntity, UserFailure>> signIn() async {
    final scopes = ['email', 'profile'];

    final String? idToken;
    final String accessToken;
    try {
      final googleUser = await googleSignInClient.authenticate();
      final authorization =
          await googleUser.authorizationClient.authorizationForScopes(scopes) ??
          await googleUser.authorizationClient.authorizeScopes(scopes);
      idToken = googleUser.authentication.idToken;
      accessToken = authorization.accessToken;
    } on GoogleSignInException catch (e) {
      debugPrint(
        '[AuthRepository] Google sign-in failed: ${e.code} ${e.description}',
      );
      return Failure(
        e.code == GoogleSignInExceptionCode.canceled
            ? const GoogleSignInCanceledFailure()
            : const GoogleSignInUnavailableFailure(),
      );
    } catch (e) {
      debugPrint('[AuthRepository] Google sign-in failed: $e');
      return const Failure(GoogleSignInUnavailableFailure());
    }

    if (idToken == null) {
      debugPrint('[AuthRepository] Google sign-in returned no idToken');
      return const Failure(GoogleSignInUnavailableFailure());
    }

    final response = await supabaseService.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );

    if (response case Failure(:final failure)) {
      return Failure(userFailureFromAuth(failure));
    }

    final supabaseUser = response.unwrap();
    final userEntity = UserModel.fromSupabase(supabaseUser);

    return Success(userEntity);
  }

  @override
  Future<Result<UserEntity, UserFailure>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final response = await supabaseService.signInWithPassword(
      email: email,
      password: password,
    );

    if (response case Failure(:final failure)) {
      return Failure(userFailureFromAuth(failure));
    }

    final supabaseUser = response.unwrap();
    final userEntity = UserModel.fromSupabase(supabaseUser);

    return Success(userEntity);
  }

  @override
  Future<Result<UserEntity, UserFailure>> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final response = await supabaseService.signUpWithPassword(
      email: email,
      password: password,
    );

    if (response case Failure(:final failure)) {
      return Failure(userFailureFromAuth(failure));
    }

    final supabaseUser = response.unwrap();
    final userEntity = UserModel.fromSupabase(supabaseUser);

    return Success(userEntity);
  }

  @override
  Future<Result<void, UserFailure>> logOut() async {
    try {
      await supabaseService.signOut();
    } finally {
      try {
        await googleSignInClient.signOut();
      } catch (_) {}
    }
    return const Success(null);
  }

  @override
  Future<Result<UserProfileEntity?, UserFailure>> getUserProfile(
    String userId,
  ) async {
    final result = await supabaseService.invokeFunction<UserProfileEntity?>(
      functionName: 'get-user-profile',
      decoder: UserProfileModel.fromJson,
    );

    return switch (result) {
      Success(:final data) => Success(data.data),
      Failure(:final failure) => Failure(userFailureFromFunction(failure)),
    };
  }

  @override
  Future<Result<void, UserFailure>> claimProfile(String claimToken) async {
    final result = await supabaseService.invokeFunction(
      functionName: 'claim-user-profile',
      body: {'claim_token': claimToken},
    );

    return switch (result) {
      Success() => const Success(null),
      // A function só responde 400 para token inválido ou já usado.
      Failure(:final failure)
          when failure.kind == SupabaseFailureKind.validation =>
        const Failure(ClaimTokenInvalidFailure()),
      Failure(:final failure) => Failure(userFailureFromFunction(failure)),
    };
  }
}
