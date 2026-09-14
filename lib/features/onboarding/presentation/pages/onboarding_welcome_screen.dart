import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/home/presentation/routes/home_routes.dart';

class OnboardingWelcomeScreen extends StatelessWidget {
  const OnboardingWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final spacing = context.spacing;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: colors.surfaceDefault,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing.s32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              Text(
                l10n.onboardingWelcomeTitle,
                style: text.headingH1.copyWith(color: colors.textDefault),
                textAlign: TextAlign.center,
              ),
              const Gap16(),
              Text(
                l10n.onboardingWelcomeSubtitle,
                style: text.bodyDefaultEmphasis.copyWith(color: colors.textMuted),
                textAlign: TextAlign.center,
              ),
              const Gap32(),
              Icon(
                Icons.auto_stories,
                size: 120,
                color: colors.actionPrimary,
              ),

              const Spacer(),
              AppButton.primary(
                label: l10n.onboardingWelcomeButton,
                onPressed: () => context.go(HomeRoutes.home),
              ),
              SizedBox(height: spacing.s24),
            ],
          ),
        ),
      ),
    );
  }
}
