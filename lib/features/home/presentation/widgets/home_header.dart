import 'package:flutter/material.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/presentation/widgets/group_filter_chips.dart';
import 'package:mobile/features/groups/presentation/widgets/group_search_field.dart';

class HomeHeader extends StatelessWidget {
  final int selectedFilterIndex;
  final ValueChanged<int>? onFilterSelected;
  final ValueChanged<String>? onSearchChanged;
  final TextEditingController? searchController;
  final int unansweredCount;

  const HomeHeader({
    super.key,
    required this.selectedFilterIndex,
    this.onFilterSelected,
    this.onSearchChanged,
    this.searchController,
    this.unansweredCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return Padding(
      padding: EdgeInsets.fromLTRB(spacing.s16, spacing.s16, spacing.s16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const _HomeTitle(),
          SizedBox(height: spacing.s16),
          GroupSearchField(
            controller: searchController,
            onChanged: onSearchChanged,
          ),
          SizedBox(height: spacing.s16),
          GroupFilterChips(
            selectedIndex: selectedFilterIndex,
            onSelected: onFilterSelected,
            unansweredCount: unansweredCount,
          ),
        ],
      ),
    );
  }
}

class _HomeTitle extends StatelessWidget {
  const _HomeTitle();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final l10n = context.l10n;

    return Text(
      l10n.myGroupsTitle,
      style: typography.headingH2.copyWith(color: colors.textDefault),
    );
  }
}
