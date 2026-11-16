import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/auth/domain/entities/user_failure.dart';
import 'package:mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:mobile/features/auth/presentation/user_failure_message.dart';
import 'package:mobile/features/onboarding/domain/entities/city.dart';
import 'package:mobile/features/onboarding/domain/entities/user_review_profile.dart';
import 'package:mobile/features/onboarding/presentation/cubit/onboarding_review_cubit.dart';
import 'package:mobile/features/onboarding/presentation/cubit/onboarding_review_state.dart';
import 'package:mobile/features/onboarding/presentation/routes/onboarding_routes.dart';
import 'package:mobile/features/onboarding/presentation/widgets/review_step_one_form.dart';
import 'package:mobile/features/onboarding/presentation/widgets/review_step_three_form.dart';
import 'package:mobile/features/onboarding/presentation/widgets/review_step_two_form.dart';

class OnboardingReviewScreen extends StatefulWidget {
  const OnboardingReviewScreen({super.key});

  @override
  State<OnboardingReviewScreen> createState() => _OnboardingReviewScreenState();
}

class _OnboardingReviewScreenState extends State<OnboardingReviewScreen> {
  late final PageController _pageController;

  /// Uma única tentativa extra de sair da tela depois do sucesso. Sem o limite,
  /// um guard que ainda devolvesse para cá criaria um loop de redirecionamento.
  bool _retriedNavigation = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page, BuildContext context) {
    final currentState = context.read<OnboardingReviewCubit>().state;
    if (page > 0 &&
        currentState is OnboardingReviewFormState &&
        !_isLocationValid(currentState)) {
      context.showErrorToast(context.l10n.onboardingLocationRequired);
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      return;
    }
    context.read<OnboardingReviewCubit>().goToStep(page);
  }

  City? _selectedCity(UserReviewProfile profile, List<City> cities) {
    for (final city in cities) {
      if (city.id == profile.cityId) return city;
    }
    return null;
  }

  bool _isLocationValid(OnboardingReviewFormState state) {
    final city = _selectedCity(state.profile, state.cities);
    if (city == null) return false;
    if (city.zones.isEmpty) return true;
    return city.zones.any((zone) => zone.id == state.profile.zoneId);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final spacing = context.spacing;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: colors.surfaceDefault,
      body: SafeArea(
        child: BlocConsumer<OnboardingReviewCubit, OnboardingReviewState>(
          listener: (context, state) {
            if (state is OnboardingReviewSuccess) {
              final profile = state.profile;
              // Cidade é o que libera a revisão; zona pode ser nula quando a
              // cidade não tem zonas cadastradas. Exigir as duas aqui deixava a
              // sessão com `cityId` nulo e o guard devolvia para esta tela.
              if (profile.cityId != null) {
                context.read<SessionCubit>().updateProfileLocation(
                  cityId: profile.cityId,
                  cityName: profile.cityName,
                  zoneId: profile.zoneId,
                  zoneName: profile.zoneName,
                );
              }
              context.go(OnboardingRoutes.welcome);
              return;
            }

            final submitFailure = state is OnboardingReviewFormState
                ? state.submitFailure
                : null;
            if (submitFailure != null) {
              context.showErrorToast(
                userFailureMessage(
                  l10n,
                  submitFailure,
                  fallback: l10n.onboardingProfileSaveError,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is OnboardingReviewLoadingProfile ||
                state is OnboardingReviewInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is OnboardingReviewLoadError) {
              final failure = state.failure;
              final sessionExpired = failure is UserSessionExpiredFailure;
              return AppErrorState(
                message: userFailureMessage(
                  l10n,
                  failure,
                  fallback: l10n.onboardingProfileLoadError,
                ),
                onRetry: userFailureIsRetryable(failure)
                    ? context.read<OnboardingReviewCubit>().loadProfileData
                    : null,
                secondaryLabel: sessionExpired ? l10n.logoutTooltip : null,
                onSecondary: sessionExpired
                    ? () => context.read<SessionCubit>().logOut()
                    : null,
              );
            }

            if (state is OnboardingReviewFormState) {
              final step = state.currentStep;

              return Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(spacing.s16),
                    child: AppStepIndicator(currentStep: step),
                  ),
                  Text(
                    l10n.onboardingReviewTitle,
                    style: text.headingH2.copyWith(color: colors.textDefault),
                    textAlign: TextAlign.center,
                  ),
                  const Gap24(),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (page) => _onPageChanged(page, context),
                      children: [
                        ReviewStepOneForm(
                          profile: state.profile,
                          cities: state.cities,
                          onChanged: (p) =>
                              context.read<OnboardingReviewCubit>().updateProfile(p),
                        ),
                        ReviewStepTwoForm(
                          profile: state.profile,
                          onChanged: (p) =>
                              context.read<OnboardingReviewCubit>().updateProfile(p),
                        ),
                        ReviewStepThreeForm(
                          profile: state.profile,
                          onChanged: (p) =>
                              context.read<OnboardingReviewCubit>().updateProfile(p),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(spacing.s16),
                    child: Row(
                      children: [
                        Expanded(
                          child: AppButton.secondary(
                            label: l10n.onboardingBackButton,
                            onPressed: step == 0
                                ? null
                                : () {
                                    _pageController.previousPage(
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  },
                          ),
                        ),
                        SizedBox(width: spacing.s8),
                        Expanded(
                          child: AppButton.primary(
                            label: l10n.onboardingContinueButton,
                            isLoading: state.isSubmitting,
                            onPressed: state.isSubmitting
                                ? null
                                : () {
                                    if (!_isLocationValid(state)) {
                                      context.showErrorToast(
                                        l10n.onboardingLocationRequired,
                                      );
                                      return;
                                    }
                                    if (step < 2) {
                                      _pageController.nextPage(
                                        duration: const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                      );
                                    } else {
                                      context
                                          .read<OnboardingReviewCubit>()
                                          .submitReview();
                                    }
                                  },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            if (state is OnboardingReviewSuccess) {
              // A navegação acontece no listener. Se o guard devolver a leitora
              // para cá, o estado continua `Success` e o listener não dispara
              // de novo: sem este retry a tela ficaria girando para sempre.
              if (!_retriedNavigation) {
                _retriedNavigation = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (context.mounted) context.go(OnboardingRoutes.welcome);
                });
              }
              return const Center(child: CircularProgressIndicator());
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
