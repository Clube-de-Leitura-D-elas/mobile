import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/auth/domain/entities/user_entity.dart';
import 'package:mobile/features/auth/domain/entities/user_failure.dart';
import 'package:mobile/features/auth/domain/entities/user_profile_entity.dart';

abstract interface class AuthRepository {
  Future<Result<UserEntity, UserFailure>> signIn();
  Future<Result<UserEntity, UserFailure>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });
  Future<Result<void, UserFailure>> logOut();
  Future<Result<UserProfileEntity?, UserFailure>> getUserProfile(String userId);
  Future<Result<void, UserFailure>> claimProfile(String claimToken);
}
