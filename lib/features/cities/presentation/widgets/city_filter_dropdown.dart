import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/cities/domain/entities/discovery_city_entity.dart';

/// Filtro de cidade: "Todas as cidades" (`null`) seguido das [cities].
class CityFilterDropdown extends StatelessWidget {
  final List<DiscoveryCityEntity> cities;

  /// `null` é "Todas as cidades".
  final DiscoveryCityEntity? value;
  final ValueChanged<DiscoveryCityEntity?> onChanged;

  const CityFilterDropdown({
    super.key,
    required this.cities,
    required this.value,
    required this.onChanged,
  });

  // Com `value` nulo o AppDropdown mostra o hint apagado, como se nada
  // estivesse escolhido; "Todas as cidades" é uma opção de verdade.
  static const _allCities = DiscoveryCityEntity(id: '', name: '', uf: '');

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final selected = value ?? _allCities;
    String labelOf(DiscoveryCityEntity city) => city == _allCities
        ? l10n.cityFilterAll
        : l10n.cityFilterOption(city.name, city.uf);

    // O AppDropdown não expõe o valor escolhido na semântica.
    return MergeSemantics(
      child: Semantics(
        value: labelOf(selected),
        child: AppDropdown<DiscoveryCityEntity>(
          label: l10n.cityFilterLabel,
          size: AppDropdownSize.lg,
          items: [
            _allCities,
            ...cities,
            // A cidade escolhida segue nas opções mesmo se a lista mudou.
            if (selected != _allCities && !cities.contains(selected)) selected,
          ],
          value: selected,
          itemLabelBuilder: labelOf,
          onChanged: (city) => onChanged(city == _allCities ? null : city),
        ),
      ),
    );
  }
}
