import 'package:flutter/material.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/domain/entities/group_entity.dart';
import 'package:mobile/features/groups/presentation/widgets/app_group_card.dart';
import 'package:mobile/features/groups/presentation/widgets/groups_empty_state.dart';

class HomeGroupsList extends StatelessWidget {
  final List<GroupEntity> groups;
  final bool isLoading;
  final String? errorMessage;
  final bool Function(String groupId) isExpanded;
  final ValueChanged<String> onToggleExpanded;
  final VoidCallback onRetry;

  const HomeGroupsList({
    super.key,
    required this.groups,
    required this.isLoading,
    required this.errorMessage,
    required this.isExpanded,
    required this.onToggleExpanded,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    if (errorMessage != null) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: _GroupsLoadError(message: errorMessage!, onRetry: onRetry),
      );
    }

    if (isLoading) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (groups.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: GroupsEmptyState(),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.all(spacing.s16),
      sliver: SliverList.separated(
        itemCount: groups.length,
        separatorBuilder: (context, index) => SizedBox(height: spacing.s16),
        itemBuilder: (context, index) => _GroupCardItem(
          group: groups[index],
          isExpanded: isExpanded(groups[index].id),
          onToggle: () => onToggleExpanded(groups[index].id),
        ),
      ),
    );
  }
}

class _GroupsLoadError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _GroupsLoadError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(spacing.s24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            SizedBox(height: spacing.s16),
            AppButton.secondary(
              label: context.l10n.groupParticipantsRetryButton,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupCardItem extends StatelessWidget {
  final GroupEntity group;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _GroupCardItem({
    required this.group,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return AppGroupCard(
      key: ValueKey('group_card_${group.id}'),
      groupId: group.id,
      groupName: group.name,
      participantsCount: group.participantsCount,
      cityState: group.cityState,
      photoUrl: group.photoUrl,
      nextMeeting: group.nextMeeting,
      expanded: isExpanded,
      onToggleExpanded: onToggle,
    );
  }
}
