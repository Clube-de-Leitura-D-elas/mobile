import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/auth/domain/entities/user_failure.dart';
import 'package:mobile/features/onboarding/domain/entities/city.dart';
import 'package:mobile/features/onboarding/domain/entities/user_review_profile.dart';
import 'package:mobile/features/onboarding/domain/entities/zone.dart';
import 'package:mobile/features/onboarding/domain/repository/onboarding_repository.dart';
import 'package:mobile/features/onboarding/presentation/cubit/onboarding_review_cubit.dart';
import 'package:mobile/features/onboarding/presentation/cubit/onboarding_review_state.dart';
import 'package:mocktail/mocktail.dart';

class MockOnboardingRepository extends Mock implements OnboardingRepository {}

const cityWithZone = City(
  id: 'city-1',
  name: 'Porto Alegre',
  uf: 'RS',
  zones: [Zone(id: 'zone-1', name: 'Zona Sul')],
);

const profileWithLocation = UserReviewProfile(
  name: 'Maria',
  cityId: 'city-1',
  zoneId: 'zone-1',
);

const profileWithoutLocation = UserReviewProfile(name: 'Maria');

const cityWithoutZones = City(id: 'city-2', name: 'Recife', uf: 'PE');

const profileCityWithoutZone = UserReviewProfile(
  name: 'Maria',
  cityId: 'city-2',
);

const profileWithCityButNoZone = UserReviewProfile(
  name: 'Maria',
  cityId: 'city-1',
);

void main() {
  late MockOnboardingRepository mockRepository;

  setUp(() {
    mockRepository = MockOnboardingRepository();
    registerFallbackValue(const UserReviewProfile());
    when(() => mockRepository.getUserProfile()).thenAnswer(
      (_) async => const Success(profileWithLocation),
    );
    when(() => mockRepository.getCitiesAndZones()).thenAnswer(
      (_) async => const Success([cityWithZone]),
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
          cities: [cityWithZone],
        ),
      ],
    );

    blocTest<OnboardingReviewCubit, OnboardingReviewState>(
      'clears ids that are not in the city list',
      build: () {
        when(() => mockRepository.getUserProfile()).thenAnswer(
          (_) async => const Success(profileWithLocation),
        );
        when(() => mockRepository.getCitiesAndZones()).thenAnswer(
          (_) async => const Success([]),
        );
        return OnboardingReviewCubit(onboardingRepository: mockRepository);
      },
      expect: () => [
        const OnboardingReviewFormState(
          currentStep: 0,
          profile: profileWithoutLocation,
        ),
      ],
    );

    blocTest<OnboardingReviewCubit, OnboardingReviewState>(
      'navigates steps forward and backward correctly',
      build: () => OnboardingReviewCubit(onboardingRepository: mockRepository),
      seed: () => const OnboardingReviewFormState(
        currentStep: 0,
        profile: profileWithLocation,
        cities: [cityWithZone],
      ),
      act: (cubit) {
        cubit.nextStep();
        cubit.previousStep();
      },
      expect: () => [
        const OnboardingReviewFormState(
          currentStep: 1,
          profile: profileWithLocation,
          cities: [cityWithZone],
        ),
        const OnboardingReviewFormState(
          currentStep: 0,
          profile: profileWithLocation,
          cities: [cityWithZone],
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
        cities: [cityWithZone],
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
        cities: [cityWithZone],
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
          cities: [cityWithZone],
        ),
      ],
    );

    blocTest<OnboardingReviewCubit, OnboardingReviewState>(
      'advances when the city has no zones and the zone is null',
      build: () {
        when(() => mockRepository.getUserProfile()).thenAnswer(
          (_) async => const Success(profileCityWithoutZone),
        );
        when(() => mockRepository.getCitiesAndZones()).thenAnswer(
          (_) async => const Success([cityWithoutZones]),
        );
        return OnboardingReviewCubit(onboardingRepository: mockRepository);
      },
      seed: () => const OnboardingReviewFormState(
        currentStep: 0,
        profile: profileCityWithoutZone,
        cities: [cityWithoutZones],
      ),
      act: (cubit) async {
        await Future<void>.delayed(Duration.zero);
        cubit.nextStep();
      },
      expect: () => [
        const OnboardingReviewFormState(
          currentStep: 1,
          profile: profileCityWithoutZone,
          cities: [cityWithoutZones],
        ),
      ],
    );

    blocTest<OnboardingReviewCubit, OnboardingReviewState>(
      'does not advance when the city has zones and the zone is null',
      build: () {
        when(() => mockRepository.getUserProfile()).thenAnswer(
          (_) async => const Success(profileWithCityButNoZone),
        );
        return OnboardingReviewCubit(onboardingRepository: mockRepository);
      },
      seed: () => const OnboardingReviewFormState(
        currentStep: 0,
        profile: profileWithCityButNoZone,
        cities: [cityWithZone],
      ),
      act: (cubit) async {
        await Future<void>.delayed(Duration.zero);
        cubit.nextStep();
      },
      expect: () => [],
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
        cities: [cityWithZone],
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
        cities: [cityWithZone],
      ),
      act: (cubit) => cubit.submitReview(),
      expect: () => [
        const OnboardingReviewFormState(
          currentStep: 2,
          profile: profileWithLocation,
          cities: [cityWithZone],
          isSubmitting: true,
        ),
        const OnboardingReviewSuccess(profileWithLocation),
        const OnboardingReviewFormState(
          currentStep: 0,
          profile: profileWithLocation,
          cities: [cityWithZone],
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
        cities: [cityWithZone],
      ),
      act: (cubit) => cubit.submitReview(),
      skip: 1,
      expect: () => [
        const OnboardingReviewFormState(
          currentStep: 2,
          profile: profileWithLocation,
          cities: [cityWithZone],
          submitFailure: UnknownUserFailure(),
        ),
        const OnboardingReviewFormState(
          currentStep: 0,
          profile: profileWithLocation,
          cities: [cityWithZone],
        ),
      ],
    );
  });
}
