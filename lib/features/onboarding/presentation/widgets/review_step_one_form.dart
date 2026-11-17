import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/onboarding/domain/entities/city.dart';
import 'package:mobile/features/onboarding/domain/entities/user_review_profile.dart';
import 'package:mobile/features/onboarding/domain/entities/zone.dart';

class ReviewStepOneForm extends StatelessWidget {
  final UserReviewProfile profile;
  final List<City> cities;
  final ValueChanged<UserReviewProfile> onChanged;

  const ReviewStepOneForm({
    super.key,
    required this.profile,
    this.cities = const [],
    required this.onChanged,
  });

  City? _selectedCity() {
    for (final city in cities) {
      if (city.id == profile.cityId) return city;
    }
    return null;
  }

  Zone? _selectedZone(City? city) {
    if (city == null) return null;
    for (final zone in city.zones) {
      if (zone.id == profile.zoneId) return zone;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.spacing;
    final selectedCity = _selectedCity();
    final selectedZone = _selectedZone(selectedCity);
    final cityHasZones = selectedCity?.zones.isNotEmpty ?? false;

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
          // E-mail de login, confirmado no claim: não é editável aqui.
          AppTextField(
            label: l10n.onboardingEmailLabel,
            initialValue: profile.email,
            enabled: false,
            keyboardType: TextInputType.emailAddress,
          ),
          const Gap16(),
          AppTextField(
            label: l10n.onboardingPhoneLabel,
            initialValue: const PhoneInputFormatter().format(profile.phone),
            keyboardType: TextInputType.phone,
            inputFormatters: const [PhoneInputFormatter()],
            onChanged: (val) => onChanged(profile.copyWith(phone: val)),
          ),
          const Gap16(),
          AppTextField(
            label: l10n.onboardingBirthDateLabel,
            hintText: l10n.onboardingBirthDateHint,
            initialValue: const DateInputFormatter().format(profile.birthDate),
            keyboardType: TextInputType.datetime,
            inputFormatters: const [DateInputFormatter()],
            onChanged: (val) => onChanged(profile.copyWith(birthDate: val)),
          ),
          const Gap16(),
          AppDropdown<City>(
            label: l10n.onboardingCityLabel,
            hintText: l10n.onboardingCityHint,
            items: cities,
            value: selectedCity,
            itemLabelBuilder: (city) => city.name,
            onChanged: (city) => onChanged(
              profile.copyWith(
                cityId: city.id,
                cityName: city.name,
                clearZone: true,
              ),
            ),
          ),
          const Gap16(),
          AppDropdown<Zone>(
            label: l10n.onboardingRegionLabel,
            hintText: selectedCity != null && !cityHasZones
                ? l10n.onboardingNoZonesHint
                : l10n.onboardingRegionHint,
            items: selectedCity?.zones ?? const [],
            value: selectedZone,
            enabled: cityHasZones,
            itemLabelBuilder: (zone) => zone.name,
            onChanged: (zone) => onChanged(
              profile.copyWith(zoneId: zone.id, zoneName: zone.name),
            ),
          ),
        ],
      ),
    );
  }
}
