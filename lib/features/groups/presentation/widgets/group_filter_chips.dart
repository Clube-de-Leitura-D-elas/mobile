import 'package:flutter/material.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';

class GroupFilterChips extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int>? onSelected;
  final int unansweredCount;

  const GroupFilterChips({
    super.key,
    this.selectedIndex = 0,
    this.onSelected,
    this.unansweredCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final chips = [
      l10n.filterAll,
      l10n.filterUnanswered(unansweredCount),
      l10n.filterAnswered,
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(chips.length, (index) {
          final isSelected = index == selectedIndex;
          return Padding(
            padding: EdgeInsets.only(right: index == chips.length - 1 ? 0 : 8),
            child: _FilterChipItem(
              label: chips[index],
              isSelected: isSelected,
              onTap: onSelected != null ? () => onSelected!(index) : null,
            ),
          );
        }),
      ),
    );
  }
}

class _FilterChipItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const _FilterChipItem({
    required this.label,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    final bgColor = isSelected ? colors.surfaceBrandSoft : colors.bgSubtle;
    final borderColor = isSelected ? colors.borderBrand : colors.borderStrong;
    final textColor = isSelected ? colors.textBrand : colors.textMuted;

    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(62),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(62),
            border: Border.all(color: borderColor),
          ),
          child: Text(
            label,
            style: typography.labelTag.copyWith(
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
