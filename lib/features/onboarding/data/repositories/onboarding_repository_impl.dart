import 'package:mobile/core/supabase/supabase_service.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/auth/domain/entities/user_failure.dart';
import 'package:mobile/features/onboarding/domain/entities/user_review_profile.dart';
import 'package:mobile/features/onboarding/domain/repository/onboarding_repository.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  final SupabaseService supabaseService;

  const OnboardingRepositoryImpl({required this.supabaseService});

  @override
  Future<Result<UserReviewProfile, UserFailure>> getUserProfile() async {
    final response = await supabaseService.invokeFunction(
      functionName: 'get-user-profile',
      decoder: (json) {
        if (json is Map<String, dynamic> && json['profile'] != null) {
          final p = json['profile'] as Map<String, dynamic>;
          return UserReviewProfile(
            name: p['name'] as String? ?? '',
            email: p['email'] as String? ?? '',
            phone: p['phone'] as String? ?? '',
            birthDate: p['birth_date'] as String? ?? '',
            job: p['job'] as String? ?? '',
            levelOfEducation: p['level_of_education'] as String? ?? '',
          );
        }
        return const UserReviewProfile();
      },
    );

    if (response case Failure(:final failure)) {
      return Failure(UserFailure(message: failure.message));
    }

    return Success(response.unwrap().data ?? const UserReviewProfile());

  }

  @override
  Future<Result<void, UserFailure>> updateUserProfile(
    UserReviewProfile profile,
  ) async {
    final body = {
      'name': profile.name,
      'email': profile.email,
      'phone': profile.phone,
      'birth_date': profile.birthDate,
      'city_name': profile.city,
      'zone_name': profile.region,
      'job': profile.job,
      'level_of_education': profile.levelOfEducation,
      'other_group_interest': profile.otherReadingGroup,
      'coordinator_interest': profile.volunteerCoordinator,
      'suggested_book': profile.bookIndication,
      'expectations': profile.expectations,
    };

    final response = await supabaseService.invokeFunction(
      functionName: 'update-user-profile',
      body: body,
    );

    if (response case Failure(:final failure)) {
      return Failure(UserFailure(message: failure.message));
    }

    return const Success(null);
  }

}
