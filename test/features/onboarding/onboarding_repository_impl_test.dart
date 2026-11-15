import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/supabase/supabase_failure.dart';
import 'package:mobile/core/supabase/supabase_response.dart';
import 'package:mobile/core/supabase/supabase_service.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/auth/domain/entities/user_failure.dart';
import 'package:mobile/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'package:mobile/features/onboarding/domain/entities/city.dart';
import 'package:mobile/features/onboarding/domain/entities/user_review_profile.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseService extends Mock implements SupabaseService {}

void main() {
  late MockSupabaseService mockSupabaseService;
  late OnboardingRepositoryImpl repository;

  setUp(() {
    mockSupabaseService = MockSupabaseService();
    repository = OnboardingRepositoryImpl(supabaseService: mockSupabaseService);
  });

  group('OnboardingRepositoryImpl', () {
    test('getUserProfile parses city, zone, book and review answers', () async {
      when(
        () => mockSupabaseService.invokeFunction<UserReviewProfile>(
          functionName: 'get-user-profile',
          decoder: any(named: 'decoder'),
        ),
      ).thenAnswer((invocation) async {
        final decoder =
            invocation.namedArguments[#decoder] as UserReviewProfile Function(
              dynamic,
            );
        final profile = decoder({
          'profile': {
            'name': 'Maria',
            'email': 'maria@gmail.com',
            'phone': '51999999999',
            'birth_date': '1990-03-05',
            'city': {'id': 'city-1', 'name': 'Porto Alegre'},
            'zone': {'id': 'zone-1', 'name': 'Zona Sul'},
            'book_name': 'A hora da estrela',
            'expectations': 'Ler mais',
            'has_other_reading_group': true,
            'wants_to_coordinate': false,
          },
        });
        return Success(SupabaseResponse<UserReviewProfile>(data: profile));
      });

      final result = await repository.getUserProfile();

      expect(result, isA<Success<UserReviewProfile, UserFailure>>());
      final profile = result.unwrap();
      expect(profile.name, 'Maria');
      expect(profile.birthDate, '05/03/1990');
      expect(profile.cityId, 'city-1');
      expect(profile.cityName, 'Porto Alegre');
      expect(profile.zoneId, 'zone-1');
      expect(profile.zoneName, 'Zona Sul');
      expect(profile.bookIndication, 'A hora da estrela');
      expect(profile.expectations, 'Ler mais');
      expect(profile.hasOtherReadingGroup, isTrue);
      expect(profile.wantsToCoordinate, isFalse);
    });

    test('getUserProfile returns Failure when invokeFunction fails', () async {
      when(
        () => mockSupabaseService.invokeFunction<UserReviewProfile>(
          functionName: 'get-user-profile',
          decoder: any(named: 'decoder'),
        ),
      ).thenAnswer(
        (_) async => const Failure(
          FunctionSupabaseFailure(message: 'Server error'),
        ),
      );

      final result = await repository.getUserProfile();

      expect(result, isA<Failure<UserReviewProfile, UserFailure>>());
    });

    test('getCitiesAndZones calls the reference function and parses zones', () async {
      when(
        () => mockSupabaseService.invokeFunction<List<City>>(
          functionName: 'get-cities-and-zones',
          method: HttpMethod.get,
          decoder: any(named: 'decoder'),
        ),
      ).thenAnswer((invocation) async {
        final decoder =
            invocation.namedArguments[#decoder] as List<City> Function(dynamic);
        final cities = decoder([
          {
            'id': 'city-1',
            'name': 'Porto Alegre',
            'uf': 'RS',
            'zones': [
              {'id': 'zone-1', 'name': 'Zona Sul'},
            ],
          },
        ]);
        return Success(SupabaseResponse<List<City>>(data: cities));
      });

      final result = await repository.getCitiesAndZones();

      expect(result, isA<Success<List<City>, UserFailure>>());
      final cities = result.unwrap();
      expect(cities, hasLength(1));
      expect(cities.first.name, 'Porto Alegre');
      expect(cities.first.zones.single.name, 'Zona Sul');
    });

    test('updateUserProfile sends booleans and saves the review answers', () async {
      Map<String, dynamic>? updateBody;
      Map<String, dynamic>? reviewBody;

      when(
        () => mockSupabaseService.invokeFunction<dynamic>(
          functionName: 'update-user-profile',
          body: any(named: 'body'),
        ),
      ).thenAnswer((invocation) async {
        updateBody = invocation.namedArguments[#body] as Map<String, dynamic>?;
        return const Success(SupabaseResponse<dynamic>(data: null));
      });
      when(
        () => mockSupabaseService.invokeFunction<dynamic>(
          functionName: 'save-onboarding-review',
          body: any(named: 'body'),
        ),
      ).thenAnswer((invocation) async {
        reviewBody = invocation.namedArguments[#body] as Map<String, dynamic>?;
        return const Success(SupabaseResponse<dynamic>(data: null));
      });

      final result = await repository.updateUserProfile(
        const UserReviewProfile(
          name: 'Maria',
          email: 'maria@example.com',
          phone: '51999999999',
          birthDate: '05/03/1990',
          cityId: 'city-1',
          cityName: 'Porto Alegre',
          zoneId: 'zone-1',
          zoneName: 'Zona Sul',
          job: 'Designer',
          levelOfEducation: 'UNDERGRADUATE',
          hasOtherReadingGroup: true,
          wantsToCoordinate: false,
          bookIndication: 'A hora da estrela',
          expectations: 'Ler mais',
        ),
      );

      expect(result, isA<Success<void, UserFailure>>());
      expect(updateBody?['city_name'], 'Porto Alegre');
      expect(updateBody?['zone_name'], 'Zona Sul');
      expect(updateBody?['other_group_interest'], isTrue);
      expect(updateBody?['coordinator_interest'], isFalse);
      expect(reviewBody?['has_other_reading_group'], isTrue);
      expect(reviewBody?['wants_to_coordinate'], isFalse);
      expect(reviewBody?['expectations'], 'Ler mais');
    });

    test('updateUserProfile returns failure when the review call fails', () async {
      when(
        () => mockSupabaseService.invokeFunction<dynamic>(
          functionName: 'update-user-profile',
          body: any(named: 'body'),
        ),
      ).thenAnswer(
        (_) async => const Success(SupabaseResponse<dynamic>(data: null)),
      );
      when(
        () => mockSupabaseService.invokeFunction<dynamic>(
          functionName: 'save-onboarding-review',
          body: any(named: 'body'),
        ),
      ).thenAnswer(
        (_) async => const Failure(
          FunctionSupabaseFailure(message: 'Failed to fetch'),
        ),
      );

      final result = await repository.updateUserProfile(
        const UserReviewProfile(name: 'Maria'),
      );

      expect(result, isA<Failure<void, UserFailure>>());
    });

    test('updateUserProfile maps a network failure', () async {
      when(
        () => mockSupabaseService.invokeFunction<dynamic>(
          functionName: 'update-user-profile',
          body: any(named: 'body'),
        ),
      ).thenAnswer(
        (_) async => const Failure(
          FunctionSupabaseFailure(
            message: 'Failed to fetch',
            kind: SupabaseFailureKind.network,
          ),
        ),
      );

      final result = await repository.updateUserProfile(
        const UserReviewProfile(name: 'Maria'),
      );

      expect(result, const Failure<void, UserFailure>(UserNetworkFailure()));
    });
  });
}
