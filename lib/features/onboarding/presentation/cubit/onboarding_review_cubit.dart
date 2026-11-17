import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/onboarding/domain/entities/city.dart';
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

    // As duas chamadas são independentes; esperar em paralelo evita uma ida
    // extra ao servidor quando o formulário abre.
    final profileFuture = onboardingRepository.getUserProfile();
    final citiesFuture = onboardingRepository.getCitiesAndZones();

    final profileResult = await profileFuture;
    if (isClosed) return;

    final UserReviewProfile profile;
    switch (profileResult) {
      case Success(:final data):
        profile = data;
      case Failure(:final failure):
        emit(OnboardingReviewLoadError(failure));
        return;
    }

    final citiesResult = await citiesFuture;
    if (isClosed) return;

    final List<City> cities;
    switch (citiesResult) {
      case Success(:final data):
        cities = data;
      case Failure(:final failure):
        emit(OnboardingReviewLoadError(failure));
        return;
    }

    // Id que não está na lista de cidades/zonas não vale: o select abre
    // vazio, mas o id antigo ainda passaria no guard. Limpa para os dois
    // concordarem.
    var safeProfile = profile;
    City? city;
    for (final candidate in cities) {
      if (candidate.id == profile.cityId) {
        city = candidate;
        break;
      }
    }

    if (city == null) {
      safeProfile = safeProfile.copyWith(clearCity: true, clearZone: true);
    } else {
      final hasZone = city.zones.any((zone) => zone.id == profile.zoneId);
      if (!hasZone) {
        safeProfile = safeProfile.copyWith(clearZone: true);
      }
    }

    emit(
      OnboardingReviewFormState(
        currentStep: 0,
        profile: safeProfile,
        cities: cities,
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

  City? _selectedCity(UserReviewProfile profile, List<City> cities) {
    for (final city in cities) {
      if (city.id == profile.cityId) return city;
    }
    return null;
  }

  // Cidade é obrigatória. Zona só quando a cidade cadastrada tem zonas; cidade
  // sem zona pode seguir com zoneId nulo.
  bool _isLocationValid(UserReviewProfile profile, List<City> cities) {
    final city = _selectedCity(profile, cities);
    if (city == null) return false;
    if (city.zones.isEmpty) return true;
    return city.zones.any((zone) => zone.id == profile.zoneId);
  }

  void nextStep() {
    final currentState = state;
    if (currentState is OnboardingReviewFormState) {
      if (currentState.currentStep == 0 &&
          !_isLocationValid(currentState.profile, currentState.cities)) {
        return;
      }
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
    // Sem cidade (e sem a zona obrigatória da cidade) a revisão continua
    // pendente; o guard devolveria a leitora para cá depois de salvar.
    if (!_isLocationValid(currentState.profile, currentState.cities)) return;

    emit(currentState.copyWith(isSubmitting: true));

    final result = await onboardingRepository.updateUserProfile(
      currentState.profile,
    );

    if (result case Failure(:final failure)) {
      emit(
        currentState.copyWith(
          isSubmitting: false,
          submitFailure: failure,
        ),
      );
      return;
    }

    emit(OnboardingReviewSuccess(currentState.profile));
  }
}
