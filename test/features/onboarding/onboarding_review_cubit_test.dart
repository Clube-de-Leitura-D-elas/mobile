import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/onboarding/domain/entities/user_review_profile.dart';
import 'package:mobile/features/onboarding/domain/repository/onboarding_repository.dart';
import 'package:mobile/features/onboarding/presentation/cubit/onboarding_review_cubit.dart';
import 'package:mobile/features/onboarding/presentation/cubit/onboarding_review_state.dart';
import 'package:mocktail/mocktail.dart';

class MockOnboardingRepository extends Mock implements OnboardingRepository {}

void main() {
  late MockOnboardingRepository mockRepository;

  setUp(() {
    mockRepository = MockOnboardingRepository();
    registerFallbackValue(const UserReviewProfile());
    when(() => mockRepository.getUserProfile()).thenAnswer(
      (_) async => const Success(UserReviewProfile(name: 'Maria')),
    );
  });

  group('OnboardingReviewCubit', () {
    blocTest<OnboardingReviewCubit, OnboardingReviewState>(
      'emits [FormState] when initialised and profile fetched',
      build: () => OnboardingReviewCubit(onboardingRepository: mockRepository),
      expect: () => [
        const OnboardingReviewFormState(
          currentStep: 0,
          profile: UserReviewProfile(name: 'Maria'),
        ),
      ],
    );

    blocTest<OnboardingReviewCubit, OnboardingReviewState>(
      'navigates steps forward and backward correctly',
      build: () => OnboardingReviewCubit(onboardingRepository: mockRepository),
      seed: () => const OnboardingReviewFormState(
        currentStep: 0,
        profile: UserReviewProfile(name: 'Maria'),
      ),
      act: (cubit) {
        cubit.nextStep();
        cubit.previousStep();
      },
      expect: () => [
        const OnboardingReviewFormState(
          currentStep: 1,
          profile: UserReviewProfile(name: 'Maria'),
        ),
        const OnboardingReviewFormState(
          currentStep: 0,
          profile: UserReviewProfile(name: 'Maria'),
        ),
      ],
    );

    blocTest<OnboardingReviewCubit, OnboardingReviewState>(
      'submits review successfully and emits OnboardingReviewSuccess',
      build: () {
        when(() => mockRepository.updateUserProfile(any())).thenAnswer(
          (_) async => const Success(null),
        );
        return OnboardingReviewCubit(onboardingRepository: mockRepository);
      },
      seed: () => const OnboardingReviewFormState(
        currentStep: 2,
        profile: UserReviewProfile(name: 'Maria'),
      ),
      act: (cubit) => cubit.submitReview(),
      expect: () => [
        const OnboardingReviewFormState(
          currentStep: 2,
          profile: UserReviewProfile(name: 'Maria'),
          isSubmitting: true,
        ),
        const OnboardingReviewFormState(
          currentStep: 0,
          profile: UserReviewProfile(name: 'Maria'),
        ),
        const OnboardingReviewSuccess(),
      ],
    );
  });
}


