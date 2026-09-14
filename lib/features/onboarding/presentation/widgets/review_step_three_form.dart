import 'package:flutter/material.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/onboarding/domain/entities/user_review_profile.dart';

class ReviewStepThreeForm extends StatelessWidget {
  final UserReviewProfile profile;
  final ValueChanged<UserReviewProfile> onChanged;

  const ReviewStepThreeForm({
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
          AppDropdown<String>(
            label: l10n.onboardingOtherGroupLabel,
            helperText: 'Escolha o gênero do próximo encontro',
            hintText: l10n.selectOptionHint,
            value: profile.otherReadingGroup.isNotEmpty
                ? profile.otherReadingGroup
                : null,
            items: const [
              DropdownMenuItem(value: 'SIM', child: Text('Sim')),
              DropdownMenuItem(value: 'NAO', child: Text('Não')),
            ],
            onChanged: (val) =>
                onChanged(profile.copyWith(otherReadingGroup: val ?? '')),
          ),
          const Gap16(),
          AppDropdown<String>(
            label: l10n.onboardingVolunteerLabel,
            helperText: 'Escolha o gênero do próximo encontro',
            hintText: l10n.selectOptionHint,
            value: profile.volunteerCoordinator.isNotEmpty
                ? profile.volunteerCoordinator
                : null,
            items: const [
              DropdownMenuItem(value: 'SIM', child: Text('Sim')),
              DropdownMenuItem(value: 'NAO', child: Text('Não')),
            ],
            onChanged: (val) =>
                onChanged(profile.copyWith(volunteerCoordinator: val ?? '')),
          ),
          const Gap16(),
          AppTextField(
            label: l10n.onboardingBookIndicationLabel,
            helperText: l10n.onboardingNameHelper,
            hintText: l10n.onboardingBookIndicationHint,
            initialValue: profile.bookIndication,
            onChanged: (val) => onChanged(profile.copyWith(bookIndication: val)),
          ),
          const Gap16(),
          AppTextField(
            label: l10n.onboardingExpectationsLabel,
            helperText: l10n.onboardingNameHelper,
            hintText: l10n.onboardingExpectationsHint,
            initialValue: profile.expectations,
            maxLines: 4,
            onChanged: (val) => onChanged(profile.copyWith(expectations: val)),
          ),
        ],
      ),
    );
  }
}
