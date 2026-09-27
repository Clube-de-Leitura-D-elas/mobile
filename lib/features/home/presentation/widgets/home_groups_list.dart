import 'package:flutter/material.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/domain/entities/group_entity.dart';
import 'package:mobile/features/groups/presentation/widgets/app_group_card.dart';
import 'package:mobile/features/groups/presentation/widgets/groups_empty_state.dart';

class HomeGroupsList extends StatelessWidget {
  final List<GroupEntity> groups;
  final bool Function(String groupId) isExpanded;
  final ValueChanged<String> onToggleExpanded;

  const HomeGroupsList({
    super.key,
    required this.groups,
    required this.isExpanded,
    required this.onToggleExpanded,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

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
