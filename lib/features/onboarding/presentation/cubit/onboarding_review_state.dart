import 'package:equatable/equatable.dart';
import 'package:mobile/features/auth/domain/entities/user_failure.dart';
import 'package:mobile/features/onboarding/domain/entities/city.dart';
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

/// Os dados não carregaram. Sem eles o formulário abriria vazio e o envio
/// apagaria o cadastro.
class OnboardingReviewLoadError extends OnboardingReviewState {
  final UserFailure failure;

  const OnboardingReviewLoadError(this.failure);

  @override
  List<Object?> get props => [failure];
}

class OnboardingReviewFormState extends OnboardingReviewState {
  final int currentStep;
  final UserReviewProfile profile;
  final List<City> cities;
  final bool isSubmitting;
  final UserFailure? submitFailure;

  const OnboardingReviewFormState({
    required this.currentStep,
    required this.profile,
    this.cities = const [],
    this.isSubmitting = false,
    this.submitFailure,
  });

  OnboardingReviewFormState copyWith({
    int? currentStep,
    UserReviewProfile? profile,
    List<City>? cities,
    bool? isSubmitting,
    UserFailure? submitFailure,
  }) {
    return OnboardingReviewFormState(
      currentStep: currentStep ?? this.currentStep,
      profile: profile ?? this.profile,
      cities: cities ?? this.cities,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitFailure: submitFailure,
    );
  }

  @override
  List<Object?> get props => [
    currentStep,
    profile,
    cities,
    isSubmitting,
    submitFailure,
  ];
}

class OnboardingReviewSuccess extends OnboardingReviewState {
  final UserReviewProfile profile;

  const OnboardingReviewSuccess(this.profile);

  @override
  List<Object?> get props => [profile];
}
