import 'package:material_ui/material_ui.dart';
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
          AppDropdown<bool>(
            label: l10n.onboardingOtherGroupLabel,
            hintText: l10n.selectOptionHint,
            value: profile.hasOtherReadingGroup,
            items: const [true, false],
            itemLabelBuilder: (value) => value
                ? l10n.onboardingYes
                : l10n.onboardingNo,
            onChanged: (val) =>
                onChanged(profile.copyWith(hasOtherReadingGroup: val)),
          ),
          const Gap16(),
          AppDropdown<bool>(
            label: l10n.onboardingVolunteerLabel,
            hintText: l10n.selectOptionHint,
            value: profile.wantsToCoordinate,
            items: const [true, false],
            itemLabelBuilder: (value) => value
                ? l10n.onboardingYes
                : l10n.onboardingNo,
            onChanged: (val) =>
                onChanged(profile.copyWith(wantsToCoordinate: val)),
          ),
          const Gap16(),
          AppTextField(
            label: l10n.onboardingBookIndicationLabel,
            hintText: l10n.onboardingBookIndicationHint,
            initialValue: profile.bookIndication,
            onChanged: (val) => onChanged(profile.copyWith(bookIndication: val)),
          ),
          const Gap16(),
          AppTextField(
            label: l10n.onboardingExpectationsLabel,
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
