import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/auth/domain/entities/user_failure.dart';
import 'package:mobile/features/auth/domain/repository/auth_repository.dart';

abstract interface class ClaimProfileUseCase {
  Future<Result<void, UserFailure>> call(String claimToken);
}

class ClaimProfileUseCaseImpl implements ClaimProfileUseCase {
  final AuthRepository repository;

  ClaimProfileUseCaseImpl({required this.repository});

  @override
  Future<Result<void, UserFailure>> call(String claimToken) async {
    return await repository.claimProfile(claimToken);
  }
}
