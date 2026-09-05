import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/auth/domain/entities/user_entity.dart';
import 'package:mobile/features/auth/domain/entities/user_failure.dart';
import 'package:mobile/features/auth/domain/repository/auth_repository.dart';

abstract interface class UserSignInUseCase {
  Future<Result<UserEntity, UserFailure>> call();
}

class UserSignInUseCaseImpl implements UserSignInUseCase {
  final AuthRepository repository;

  UserSignInUseCaseImpl({required this.repository});

  @override
  Future<Result<UserEntity, UserFailure>> call() async {
    return repository.signIn();
  }
}
