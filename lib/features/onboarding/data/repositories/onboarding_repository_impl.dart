import 'package:mobile/core/supabase/supabase_service.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/auth/data/user_failure_mapper.dart';
import 'package:mobile/features/auth/domain/entities/user_failure.dart';
import 'package:mobile/features/onboarding/domain/entities/city.dart';
import 'package:mobile/features/onboarding/domain/entities/user_review_profile.dart';
import 'package:mobile/features/onboarding/domain/entities/zone.dart';
import 'package:mobile/features/onboarding/domain/repository/onboarding_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
          final cityObj = p['city'] as Map<String, dynamic>?;
          final zoneObj = p['zone'] as Map<String, dynamic>?;

          final rawBirthDate = p['birth_date'] as String? ?? '';
          String formattedBirthDate = rawBirthDate;
          if (rawBirthDate.contains('-')) {
            final parts = rawBirthDate.split('T')[0].split('-');
            if (parts.length == 3) {
              formattedBirthDate = '${parts[2]}/${parts[1]}/${parts[0]}';
            }
          }

          return UserReviewProfile(
            name: p['name'] as String? ?? '',
            email: p['email'] as String? ?? '',
            phone: p['phone'] as String? ?? '',
            birthDate: formattedBirthDate,
            cityId: cityObj?['id'] as String?,
            cityName: cityObj?['name'] as String? ?? '',
            zoneId: zoneObj?['id'] as String?,
            zoneName: zoneObj?['name'] as String? ?? '',
            job: p['job'] as String? ?? '',
            levelOfEducation: p['level_of_education'] as String? ?? '',
            hasOtherReadingGroup: p['has_other_reading_group'] as bool?,
            wantsToCoordinate: p['wants_to_coordinate'] as bool?,
            bookIndication: p['book_name'] as String? ?? '',
            expectations: p['expectations'] as String? ?? '',
          );
        }
        return const UserReviewProfile();
      },
    );

    if (response case Failure(:final failure)) {
      return Failure(userFailureFromFunction(failure));
    }

    return Success(response.unwrap().data ?? const UserReviewProfile());
  }

  @override
  Future<Result<List<City>, UserFailure>> getCitiesAndZones() async {
    final response = await supabaseService.invokeFunction<List<City>>(
      functionName: 'get-cities-and-zones',
      method: HttpMethod.get,
      decoder: (json) {
        if (json is! List) return <City>[];

        return json.map((item) {
          final map = item as Map<String, dynamic>;
          final zones = (map['zones'] as List? ?? []).map((zone) {
            final zoneMap = zone as Map<String, dynamic>;
            return Zone(
              id: zoneMap['id'] as String? ?? '',
              name: zoneMap['name'] as String? ?? '',
            );
          }).toList();

          return City(
            id: map['id'] as String? ?? '',
            name: map['name'] as String? ?? '',
            uf: map['uf'] as String? ?? '',
            zones: zones,
          );
        }).toList();
      },
    );

    if (response case Failure(:final failure)) {
      return Failure(userFailureFromFunction(failure));
    }

    return Success(response.unwrap().data ?? <City>[]);
  }

  @override
  Future<Result<void, UserFailure>> updateUserProfile(
    UserReviewProfile profile,
  ) async {
    String apiBirthDate = profile.birthDate;
    if (profile.birthDate.contains('/')) {
      final parts = profile.birthDate.split('/');
      if (parts.length == 3) {
        apiBirthDate = '${parts[2]}-${parts[1]}-${parts[0]}';
      }
    }

    final body = {
      'name': profile.name,
      'email': profile.email,
      'phone': profile.phone,
      'birth_date': apiBirthDate,
      'city_name': profile.cityName,
      'zone_name': profile.zoneName,
      'job': profile.job,
      'level_of_education': profile.levelOfEducation,
      'has_other_reading_group': profile.hasOtherReadingGroup,
      'wants_to_coordinate': profile.wantsToCoordinate,
      'suggested_book': profile.bookIndication,
      'expectations': profile.expectations,
    };

    final response = await supabaseService.invokeFunction(
      functionName: 'update-user-profile',
      body: body,
    );

    if (response case Failure(:final failure)) {
      return Failure(userFailureFromFunction(failure));
    }

    return const Success(null);
  }
}
