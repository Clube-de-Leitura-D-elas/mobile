import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/auth/domain/entities/user_failure.dart';
import 'package:mobile/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'package:mobile/features/onboarding/domain/entities/user_review_profile.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/core/supabase/supabase_failure.dart';
import 'package:mobile/core/supabase/supabase_response.dart';
import 'package:mobile/core/supabase/supabase_service.dart';

class MockSupabaseService extends Mock implements SupabaseService {}


void main() {
  late MockSupabaseService mockSupabaseService;
  late OnboardingRepositoryImpl repository;

  setUp(() {
    mockSupabaseService = MockSupabaseService();
    repository = OnboardingRepositoryImpl(supabaseService: mockSupabaseService);
  });

  group('OnboardingRepositoryImpl', () {
    test('getUserProfile returns Success with parsed UserReviewProfile', () async {
      when(
        () => mockSupabaseService.invokeFunction<UserReviewProfile>(
          functionName: 'get-user-profile',
          decoder: any(named: 'decoder'),
        ),
      ).thenAnswer(
        (_) async => const Success(
          SupabaseResponse(
            data: UserReviewProfile(
              name: 'Maria',
              email: 'maria@gmail.com',
              phone: '51999999999',
            ),
          ),
        ),
      );

      final result = await repository.getUserProfile();

      expect(result, isA<Success<UserReviewProfile, UserFailure>>());
      expect(result.unwrap().name, equals('Maria'));
    });

    test('getUserProfile returns Failure when invokeFunction fails', () async {
      when(
        () => mockSupabaseService.invokeFunction<UserReviewProfile>(
          functionName: 'get-user-profile',
          decoder: any(named: 'decoder'),
        ),
      ).thenAnswer((_) async => const Failure(FunctionSupabaseFailure(message: 'Server error')));

      final result = await repository.getUserProfile();

      expect(result, isA<Failure<UserReviewProfile, UserFailure>>());
    });


    test('updateUserProfile returns Success on successful edge function call', () async {
      when(
        () => mockSupabaseService.invokeFunction<dynamic>(
          functionName: 'update-user-profile',
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => const Success(SupabaseResponse(data: null)));

      final result = await repository.updateUserProfile(
        const UserReviewProfile(name: 'Maria'),
      );

      expect(result, isA<Success<void, UserFailure>>());
    });


  });
}
