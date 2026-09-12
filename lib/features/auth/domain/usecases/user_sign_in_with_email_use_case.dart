import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/auth/domain/entities/user_entity.dart';
import 'package:mobile/features/auth/domain/entities/user_failure.dart';
import 'package:mobile/features/auth/domain/repository/auth_repository.dart';

abstract interface class UserSignInWithEmailUseCase {
  Future<Result<UserEntity, UserFailure>> call({
    required String email,
    required String password,
  });
}

class UserSignInWithEmailUseCaseImpl implements UserSignInWithEmailUseCase {
  final AuthRepository repository;

  UserSignInWithEmailUseCaseImpl({required this.repository});

  @override
  Future<Result<UserEntity, UserFailure>> call({
    required String email,
    required String password,
  }) async {
    return repository.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}
