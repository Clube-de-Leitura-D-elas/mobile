import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/group_discovery/domain/entities/group_genre_entity.dart';
import 'package:mobile/features/group_discovery/domain/entities/group_search_filters.dart';

/// Filtros da busca de grupos. Devolve os filtros escolhidos ("Limpar"
/// devolve [GroupSearchFilters.empty]) ou `null` quando é fechado sem aplicar.
class GroupSearchFiltersDialog extends StatefulWidget {
  final GroupSearchFilters initial;
  final List<GroupGenreEntity> genres;

  const GroupSearchFiltersDialog({
    super.key,
    required this.initial,
    required this.genres,
  });

  static Future<GroupSearchFilters?> show(
    BuildContext context, {
    required GroupSearchFilters initial,
    required List<GroupGenreEntity> genres,
  }) {
    return showDialog<GroupSearchFilters>(
      context: context,
      builder: (_) =>
          GroupSearchFiltersDialog(initial: initial, genres: genres),
    );
  }

  @override
  State<GroupSearchFiltersDialog> createState() =>
      _GroupSearchFiltersDialogState();
}

class _GroupSearchFiltersDialogState extends State<GroupSearchFiltersDialog> {
  // O backend aceita até 4 dígitos.
  static const int _maxDigits = 4;

  late GroupGenreEntity? _genre = _initialGenre();
  late final TextEditingController _min = TextEditingController(
    text: widget.initial.minParticipants?.toString() ?? '',
  );
  late final TextEditingController _max = TextEditingController(
    text: widget.initial.maxParticipants?.toString() ?? '',
  );

  GroupGenreEntity? _initialGenre() {
    for (final genre in widget.genres) {
      if (genre.id == widget.initial.genreId) return genre;
    }
    return null;
  }

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
    final formatters = [
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(_maxDigits),
    ];

    return AppDialog(
      title: l10n.groupSearchFiltersButton,
      actions: [
        AppButton.secondary(
          label: l10n.groupSearchFiltersClear,
          onPressed: () => navigator.pop(GroupSearchFilters.empty),
        ),
        AppButton.primary(
          label: l10n.groupSearchFiltersApply,
          onPressed: _hasRangeError
              ? null
              : () => navigator.pop(
                  GroupSearchFilters(
                    genreId: _genre?.id,
                    minParticipants: _minValue,
                    maxParticipants: _maxValue,
                  ),
                ),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppDropdown<GroupGenreEntity?>(
            label: l10n.groupSearchFilterGenre,
            hintText: l10n.groupSearchFilterGenreAll,
            items: [null, ...widget.genres],
            value: _genre,
            itemLabelBuilder: (genre) =>
                genre?.name ?? l10n.groupSearchFilterGenreAll,
            onChanged: (genre) => setState(() => _genre = genre),
          ),
          SizedBox(height: spacing.s16),
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
