import 'package:flutter/material.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/onboarding/domain/entities/user_review_profile.dart';

class ReviewStepOneForm extends StatelessWidget {
  final UserReviewProfile profile;
  final ValueChanged<UserReviewProfile> onChanged;

  const ReviewStepOneForm({
    super.key,
    required this.profile,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.spacing;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: spacing.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            label: l10n.onboardingNameLabel,
            initialValue: profile.name,
            onChanged: (val) => onChanged(profile.copyWith(name: val)),
          ),
          const Gap16(),
          AppTextField(
            label: l10n.onboardingEmailLabel,
            initialValue: profile.email,
            keyboardType: TextInputType.emailAddress,
            onChanged: (val) => onChanged(profile.copyWith(email: val)),
          ),
          const Gap16(),
          AppTextField(
            label: l10n.onboardingPhoneLabel,
            initialValue: profile.phone,
            keyboardType: TextInputType.phone,
            onChanged: (val) => onChanged(profile.copyWith(phone: val)),
          ),
          const Gap16(),
          AppTextField(
            label: l10n.onboardingBirthDateLabel,
            initialValue: profile.birthDate,
            keyboardType: TextInputType.datetime,
            onChanged: (val) => onChanged(profile.copyWith(birthDate: val)),
          ),
          const Gap16(),
          AppTextField(
            label: l10n.onboardingCityLabel,
            initialValue: profile.city,
            keyboardType: TextInputType.text,
            onChanged: (val) => onChanged(profile.copyWith(city: val)),
          ),
          const Gap16(),
          AppTextField(
            label: l10n.onboardingRegionLabel,
            initialValue: profile.region,
            onChanged: (val) => onChanged(profile.copyWith(region: val)),
          ),
        ],
      ),
    );
  }
}
