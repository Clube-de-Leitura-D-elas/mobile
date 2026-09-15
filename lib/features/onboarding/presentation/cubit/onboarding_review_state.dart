import 'package:equatable/equatable.dart';
import 'package:mobile/features/onboarding/domain/entities/user_review_profile.dart';

abstract class OnboardingReviewState extends Equatable {
  const OnboardingReviewState();

  @override
  List<Object?> get props => [];
}

class OnboardingReviewInitial extends OnboardingReviewState {
  const OnboardingReviewInitial();
}

class OnboardingReviewLoadingProfile extends OnboardingReviewState {
  const OnboardingReviewLoadingProfile();
}

class OnboardingReviewFormState extends OnboardingReviewState {
  final int currentStep;
  final UserReviewProfile profile;
  final bool isSubmitting;
  final String? errorMessage;

  const OnboardingReviewFormState({
    required this.currentStep,
    required this.profile,
    this.isSubmitting = false,
    this.errorMessage,
  });

  OnboardingReviewFormState copyWith({
    int? currentStep,
    UserReviewProfile? profile,
    bool? isSubmitting,
    String? errorMessage,
  }) {
    return OnboardingReviewFormState(
      currentStep: currentStep ?? this.currentStep,
      profile: profile ?? this.profile,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [currentStep, profile, isSubmitting, errorMessage];
}

class OnboardingReviewSuccess extends OnboardingReviewState {
  const OnboardingReviewSuccess();
}
