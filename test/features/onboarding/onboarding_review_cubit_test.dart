import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/auth/domain/entities/user_failure.dart';
import 'package:mobile/features/onboarding/domain/entities/user_review_profile.dart';
import 'package:mobile/features/onboarding/domain/repository/onboarding_repository.dart';
import 'package:mobile/features/onboarding/presentation/cubit/onboarding_review_cubit.dart';
import 'package:mobile/features/onboarding/presentation/cubit/onboarding_review_state.dart';
import 'package:mocktail/mocktail.dart';

class MockOnboardingRepository extends Mock implements OnboardingRepository {}

const profileWithLocation = UserReviewProfile(
  name: 'Maria',
  cityId: 'city-1',
  zoneId: 'zone-1',
);

const profileWithoutLocation = UserReviewProfile(name: 'Maria');

void main() {
  late MockOnboardingRepository mockRepository;

  setUp(() {
    mockRepository = MockOnboardingRepository();
    registerFallbackValue(const UserReviewProfile());
    when(() => mockRepository.getUserProfile()).thenAnswer(
      (_) async => const Success(profileWithLocation),
    );
    when(() => mockRepository.getCitiesAndZones()).thenAnswer(
      (_) async => const Success([]),
    );
  });

  group('OnboardingReviewCubit', () {
    blocTest<OnboardingReviewCubit, OnboardingReviewState>(
      'emits [FormState] when initialised and profile fetched',
      build: () => OnboardingReviewCubit(onboardingRepository: mockRepository),
      expect: () => [
        const OnboardingReviewFormState(
          currentStep: 0,
          profile: profileWithLocation,
        ),
      ],
    );

    blocTest<OnboardingReviewCubit, OnboardingReviewState>(
      'navigates steps forward and backward correctly',
      build: () => OnboardingReviewCubit(onboardingRepository: mockRepository),
      seed: () => const OnboardingReviewFormState(
        currentStep: 0,
        profile: profileWithLocation,
      ),
      act: (cubit) {
        cubit.nextStep();
        cubit.previousStep();
      },
      expect: () => [
        const OnboardingReviewFormState(
          currentStep: 1,
          profile: profileWithLocation,
        ),
        const OnboardingReviewFormState(
          currentStep: 0,
          profile: profileWithLocation,
        ),
      ],
    );

    blocTest<OnboardingReviewCubit, OnboardingReviewState>(
      'does not advance from step 0 without city and zone',
      build: () {
        when(() => mockRepository.getUserProfile()).thenAnswer(
          (_) async => const Success(profileWithoutLocation),
        );
        return OnboardingReviewCubit(onboardingRepository: mockRepository);
      },
      seed: () => const OnboardingReviewFormState(
        currentStep: 0,
        profile: profileWithoutLocation,
      ),
      act: (cubit) => cubit.nextStep(),
      expect: () => [],
    );

    blocTest<OnboardingReviewCubit, OnboardingReviewState>(
      'advances from step 0 when city and zone are set',
      build: () => OnboardingReviewCubit(onboardingRepository: mockRepository),
      seed: () => const OnboardingReviewFormState(
        currentStep: 0,
        profile: profileWithLocation,
      ),
      act: (cubit) async {
        // Espera o load inicial terminar antes de avançar; sem isso a
        // emissão assíncrona do load aparece depois do nextStep.
        await Future<void>.delayed(Duration.zero);
        cubit.nextStep();
      },
      expect: () => [
        const OnboardingReviewFormState(
          currentStep: 1,
          profile: profileWithLocation,
        ),
      ],
    );

    blocTest<OnboardingReviewCubit, OnboardingReviewState>(
      'does not submit without city and zone',
      build: () {
        when(() => mockRepository.getUserProfile()).thenAnswer(
          (_) async => const Success(profileWithoutLocation),
        );
        when(() => mockRepository.updateUserProfile(any())).thenAnswer(
          (_) async => const Success(null),
        );
        return OnboardingReviewCubit(onboardingRepository: mockRepository);
      },
      seed: () => const OnboardingReviewFormState(
        currentStep: 2,
        profile: profileWithoutLocation,
      ),
      act: (cubit) => cubit.submitReview(),
      skip: 1,
      expect: () => [],
      verify: (_) {
        verifyNever(() => mockRepository.updateUserProfile(any()));
      },
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
        profile: profileWithLocation,
      ),
      act: (cubit) => cubit.submitReview(),
      expect: () => [
        const OnboardingReviewFormState(
          currentStep: 2,
          profile: profileWithLocation,
          isSubmitting: true,
        ),
        const OnboardingReviewSuccess(profileWithLocation),
        const OnboardingReviewFormState(
          currentStep: 0,
          profile: profileWithLocation,
        ),
      ],
    );

    blocTest<OnboardingReviewCubit, OnboardingReviewState>(
      'emits OnboardingReviewLoadError when loading cities fails',
      build: () {
        when(() => mockRepository.getCitiesAndZones()).thenAnswer(
          (_) async => const Failure(UserNetworkFailure()),
        );
        return OnboardingReviewCubit(onboardingRepository: mockRepository);
      },
      expect: () => [const OnboardingReviewLoadError(UserNetworkFailure())],
    );

    blocTest<OnboardingReviewCubit, OnboardingReviewState>(
      'emits OnboardingReviewLoadError instead of an empty form when loading fails',
      build: () {
        when(() => mockRepository.getUserProfile()).thenAnswer(
          (_) async => const Failure(UserNetworkFailure()),
        );
        return OnboardingReviewCubit(onboardingRepository: mockRepository);
      },
      expect: () => [const OnboardingReviewLoadError(UserNetworkFailure())],
    );

    blocTest<OnboardingReviewCubit, OnboardingReviewState>(
      'keeps the form and exposes submitFailure when saving fails',
      build: () {
        when(() => mockRepository.updateUserProfile(any())).thenAnswer(
          (_) async => const Failure(UnknownUserFailure()),
        );
        return OnboardingReviewCubit(onboardingRepository: mockRepository);
      },
      seed: () => const OnboardingReviewFormState(
        currentStep: 2,
        profile: profileWithLocation,
      ),
      act: (cubit) => cubit.submitReview(),
      skip: 1,
      expect: () => [
        const OnboardingReviewFormState(
          currentStep: 2,
          profile: profileWithLocation,
          submitFailure: UnknownUserFailure(),
        ),
        const OnboardingReviewFormState(
          currentStep: 0,
          profile: profileWithLocation,
        ),
      ],
    );
  });
}
