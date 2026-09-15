import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/auth/presentation/cubit/session_cubit.dart';
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
    context.read<OnboardingReviewCubit>().goToStep(page);
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
              final sessionCubit = context.read<SessionCubit>();
              final currentUser = sessionCubit.supabaseService.currentUser;
              if (currentUser != null) {
                sessionCubit.checkUserProfile(currentUser.id);
              }
              context.go(OnboardingRoutes.welcome);
              return;
            }

            if (state is OnboardingReviewFormState && state.errorMessage != null) {
              context.showAppToast(state.errorMessage!);
            }
          },
          builder: (context, state) {
            if (state is OnboardingReviewLoadingProfile ||
                state is OnboardingReviewInitial) {
              return const Center(child: CircularProgressIndicator());
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

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
