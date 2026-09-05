import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/auth/domain/entities/user_failure.dart';
import 'package:mobile/features/auth/domain/entities/user_profile_entity.dart';
import 'package:mobile/features/auth/domain/repository/auth_repository.dart';

abstract interface class GetUserProfileUseCase {
  Future<Result<UserProfileEntity?, UserFailure>> call(String userId);
}

class GetUserProfileUseCaseImpl implements GetUserProfileUseCase {
  final AuthRepository repository;

  GetUserProfileUseCaseImpl({required this.repository});

  @override
  Future<Result<UserProfileEntity?, UserFailure>> call(String userId) async {
    return await repository.getUserProfile(userId);
  }
}
