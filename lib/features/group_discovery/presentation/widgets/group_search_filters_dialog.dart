import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/cities/domain/entities/discovery_city_entity.dart';
import 'package:mobile/features/cities/presentation/widgets/city_filter_dropdown.dart';
import 'package:mobile/features/group_discovery/domain/entities/group_search_filters.dart';

/// Filtros da busca de grupos. Devolve os filtros escolhidos ("Limpar"
/// devolve [GroupSearchFilters.empty]) ou `null` quando é fechado sem aplicar.
class GroupSearchFiltersDialog extends StatefulWidget {
  final GroupSearchFilters initial;

  /// `null` esconde o filtro de cidade (a lista não carregou).
  final List<DiscoveryCityEntity>? cities;

  const GroupSearchFiltersDialog({
    super.key,
    required this.initial,
    required this.cities,
  });

  static Future<GroupSearchFilters?> show(
    BuildContext context, {
    required GroupSearchFilters initial,
    required List<DiscoveryCityEntity>? cities,
  }) {
    return showDialog<GroupSearchFilters>(
      context: context,
      builder: (_) =>
          GroupSearchFiltersDialog(initial: initial, cities: cities),
    );
  }

  @override
  State<GroupSearchFiltersDialog> createState() =>
      _GroupSearchFiltersDialogState();
}

class _GroupSearchFiltersDialogState extends State<GroupSearchFiltersDialog> {
  // O backend aceita até 4 dígitos.
  static const int _maxDigits = 4;

  late DiscoveryCityEntity? _city = widget.initial.city;
  late final TextEditingController _min = TextEditingController(
    text: widget.initial.minParticipants?.toString() ?? '',
  );
  late final TextEditingController _max = TextEditingController(
    text: widget.initial.maxParticipants?.toString() ?? '',
  );

  int? get _minValue => int.tryParse(_min.text);
  int? get _maxValue => int.tryParse(_max.text);

  bool get _hasRangeError {
    final min = _minValue;
    final max = _maxValue;
    return min != null && max != null && min > max;
  }

  @override
  void dispose() {
    _min.dispose();
    _max.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.spacing;
    final navigator = Navigator.of(context);
    final cities = widget.cities;
    final formatters = [
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(_maxDigits),
    ];

    return AppDialog(
      title: l10n.groupSearchFiltersButton,
      actions: [
        AppButton.secondary(
          label: l10n.groupSearchFiltersClear,
          size: AppButtonSize.lg,
          onPressed: () => navigator.pop(GroupSearchFilters.empty),
        ),
        AppButton.primary(
          label: l10n.groupSearchFiltersApply,
          size: AppButtonSize.lg,
          onPressed: _hasRangeError
              ? null
              : () => navigator.pop(
                  GroupSearchFilters(
                    city: _city,
                    minParticipants: _minValue,
                    maxParticipants: _maxValue,
                  ),
                ),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (cities != null) ...[
            CityFilterDropdown(
              cities: cities,
              value: _city,
              onChanged: (city) => setState(() => _city = city),
            ),
            SizedBox(height: spacing.s16),
          ],
          AppTextField(
            label: l10n.groupSearchFilterMin,
            hintText: l10n.groupSearchFilterMinHint,
            controller: _min,
            keyboardType: TextInputType.number,
            inputFormatters: formatters,
            onChanged: (_) => setState(() {}),
          ),
          SizedBox(height: spacing.s16),
          AppTextField(
            label: l10n.groupSearchFilterMax,
            hintText: l10n.groupSearchFilterMaxHint,
            controller: _max,
            keyboardType: TextInputType.number,
            inputFormatters: formatters,
            errorText: _hasRangeError ? l10n.groupSearchFilterRangeError : null,
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }
}
