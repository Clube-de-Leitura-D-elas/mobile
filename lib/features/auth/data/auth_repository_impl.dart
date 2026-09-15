import 'package:google_sign_in/google_sign_in.dart';
import 'package:mobile/core/supabase/supabase_service.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/auth/data/models/user_model.dart';
import 'package:mobile/features/auth/data/models/user_profile_model.dart';
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

    final googleUser = await googleSignInClient.authenticate();
    final authorization =
        await googleUser.authorizationClient.authorizationForScopes(scopes) ??
        await googleUser.authorizationClient.authorizeScopes(scopes);

    final idToken = googleUser.authentication.idToken;

    if (idToken == null) {
      return const Failure(
        MissingGoogleIdTokenFailure(message: 'idToken is null'),
      );
    }

    final response = await supabaseService.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: authorization.accessToken,
    );

    if (response case Failure(:final failure)) {
      return Failure(UserFailure(message: failure.message));
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
      return Failure(UserFailure(message: failure.message));
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
      return Failure(UserFailure(message: failure.message));
    }

    final supabaseUser = response.unwrap();
    final userEntity = UserModel.fromSupabase(supabaseUser);

    return Success(userEntity);
  }

  @override
  Future<Result<void, UserFailure>> logOut() async {
    await supabaseService.signOut();
    await googleSignInClient.signOut();
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
      Failure(:final failure) => Failure(UserFailure(message: failure.message)),
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
      Failure(:final failure) => Failure(UserFailure(message: failure.message)),
    };
  }
}
