import 'package:flutter/material.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/presentation/widgets/groups_empty_state.dart';
import 'package:mobile/features/home/presentation/cubit/home_state.dart';

class HomeEmptyState extends StatelessWidget {
  final HomeEmptyKind kind;

  const HomeEmptyState({super.key, required this.kind});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return switch (kind) {
      HomeEmptyKind.noGroups => const GroupsEmptyState(),
      HomeEmptyKind.noSearchResults => _EmptyMessage(l10n.emptyGroupsSearch),
      HomeEmptyKind.noUnanswered => _EmptyMessage(l10n.emptyGroupsUnanswered),
      HomeEmptyKind.noAnswered => _EmptyMessage(l10n.emptyGroupsAnswered),
    };
  }
}

class _EmptyMessage extends StatelessWidget {
  final String message;

  const _EmptyMessage(this.message);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.spacing.s24),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}
