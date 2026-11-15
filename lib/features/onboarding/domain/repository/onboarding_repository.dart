import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/auth/domain/entities/user_failure.dart';
import 'package:mobile/features/onboarding/domain/entities/city.dart';
import 'package:mobile/features/onboarding/domain/entities/user_review_profile.dart';

abstract class OnboardingRepository {
  Future<Result<UserReviewProfile, UserFailure>> getUserProfile();
  Future<Result<List<City>, UserFailure>> getCitiesAndZones();
  Future<Result<void, UserFailure>> updateUserProfile(UserReviewProfile profile);
}
