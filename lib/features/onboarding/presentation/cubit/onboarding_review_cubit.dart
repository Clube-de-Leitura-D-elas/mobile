import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/onboarding/domain/entities/user_review_profile.dart';
import 'package:mobile/features/onboarding/domain/repository/onboarding_repository.dart';
import 'package:mobile/features/onboarding/presentation/cubit/onboarding_review_state.dart';

class OnboardingReviewCubit extends Cubit<OnboardingReviewState> {
  final OnboardingRepository onboardingRepository;

  OnboardingReviewCubit({required this.onboardingRepository})
      : super(const OnboardingReviewInitial()) {
    loadProfileData();
  }

  Future<void> loadProfileData() async {
    emit(const OnboardingReviewLoadingProfile());
    final result = await onboardingRepository.getUserProfile();

    final UserReviewProfile profile;
    if (result case Success(:final data)) {
      profile = data;
    } else {
      profile = const UserReviewProfile();
    }

    emit(
      OnboardingReviewFormState(
        currentStep: 0,
        profile: profile,
      ),
    );
  }


  void updateProfile(UserReviewProfile updatedProfile) {
    final currentState = state;
    if (currentState is OnboardingReviewFormState) {
      emit(currentState.copyWith(profile: updatedProfile));
    }
  }

  void goToStep(int step) {
    final currentState = state;
    if (currentState is OnboardingReviewFormState) {
      if (step >= 0 && step <= 2) {
        emit(currentState.copyWith(currentStep: step));
      }
    }
  }

  void nextStep() {
    final currentState = state;
    if (currentState is OnboardingReviewFormState) {
      if (currentState.currentStep < 2) {
        emit(currentState.copyWith(currentStep: currentState.currentStep + 1));
      } else {
        submitReview();
      }
    }
  }

  void previousStep() {
    final currentState = state;
    if (currentState is OnboardingReviewFormState) {
      if (currentState.currentStep > 0) {
        emit(currentState.copyWith(currentStep: currentState.currentStep - 1));
      }
    }
  }

  Future<void> submitReview() async {
    final currentState = state;
    if (currentState is! OnboardingReviewFormState) return;

    emit(currentState.copyWith(isSubmitting: true, errorMessage: null));

    final result = await onboardingRepository.updateUserProfile(
      currentState.profile,
    );

    if (result case Failure(:final failure)) {
      emit(
        currentState.copyWith(
          isSubmitting: false,
          errorMessage: failure.message,
        ),
      );
      return;
    }

    emit(const OnboardingReviewSuccess());
  }
}
