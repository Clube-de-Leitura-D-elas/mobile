import 'package:flutter/material.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/onboarding/domain/entities/user_review_profile.dart';

class ReviewStepTwoForm extends StatelessWidget {
  final UserReviewProfile profile;
  final ValueChanged<UserReviewProfile> onChanged;

  const ReviewStepTwoForm({
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
            label: l10n.onboardingJobLabel,
            initialValue: profile.job,
            onChanged: (val) => onChanged(profile.copyWith(job: val)),
          ),
          const Gap16(),
          AppDropdown<String>(
            label: l10n.onboardingEducationLabel,
            hintText: l10n.onboardingEducationHint,
            value: profile.levelOfEducation.isNotEmpty
                ? profile.levelOfEducation
                : null,
            items: const [
              'ELEMENTARY',
              'HIGH_SCHOOL',
              'UNDERGRADUATE',
              'POSTGRADUATE',
            ],
            itemLabelBuilder: (item) => switch (item) {
              'ELEMENTARY' => 'Ensino fundamental',
              'HIGH_SCHOOL' => 'Ensino médio',
              'UNDERGRADUATE' => 'Ensino superior',
              'POSTGRADUATE' => 'Pós-graduação',
              _ => item,
            },
            onChanged: (val) =>
                onChanged(profile.copyWith(levelOfEducation: val)),
          ),

        ],
      ),
    );
  }
}
