import 'package:flutter/material.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/domain/entities/group_entity.dart';
import 'package:mobile/features/groups/presentation/widgets/app_group_card.dart';
import 'package:mobile/features/home/presentation/cubit/home_state.dart';
import 'package:mobile/features/home/presentation/widgets/home_empty_state.dart';
import 'package:mobile/features/groups/domain/entities/group_failure.dart';
import 'package:mobile/features/groups/presentation/widgets/group_error_state.dart';

class HomeGroupsList extends StatelessWidget {
  final List<GroupEntity> groups;
  final HomeEmptyKind? emptyKind;
  final bool isLoading;
  final GroupFailure? error;
  final bool Function(String groupId) isExpanded;
  final ValueChanged<String> onToggleExpanded;
  final VoidCallback onRetry;
  final VoidCallback onMeetingResponseSuccess;
  final bool tasksOnly;

  const HomeGroupsList({
    super.key,
    required this.groups,
    required this.emptyKind,
    required this.isLoading,
    required this.error,
    required this.isExpanded,
    required this.onToggleExpanded,
    required this.onRetry,
    required this.onMeetingResponseSuccess,
    this.tasksOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    final error = this.error;
    if (error != null) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: GroupErrorState(failure: error, onRetry: onRetry),
      );
    }

    if (isLoading) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final kind = emptyKind;
    if (kind != null) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: HomeEmptyState(kind: kind),
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
          onMeetingResponseSuccess: onMeetingResponseSuccess,
          tasksOnly: tasksOnly,
        ),
      ),
    );
  }
}

class _GroupCardItem extends StatelessWidget {
  final GroupEntity group;
  final bool isExpanded;
  final VoidCallback onToggle;
  final VoidCallback onMeetingResponseSuccess;
  final bool tasksOnly;

  const _GroupCardItem({
    required this.group,
    required this.isExpanded,
    required this.onToggle,
    required this.onMeetingResponseSuccess,
    required this.tasksOnly,
  });

  @override
  Widget build(BuildContext context) {
    return AppGroupCard(
      // Em "Tarefas pendentes" o mesmo grupo aparece uma vez por encontro.
      key: ValueKey(
        tasksOnly
            ? 'group_card_${group.id}_${group.nextMeeting?.id}'
            : 'group_card_${group.id}',
      ),
      groupId: group.id,
      groupName: context.l10n.groupDetailsNumberLabel(group.number),
      participantsCount: group.participantsCount,
      cityState: group.cityState,
      photoUrl: group.photoUrl,
      nextMeeting: group.nextMeeting,
      expanded: isExpanded,
      onToggleExpanded: onToggle,
      onMeetingResponseSuccess: onMeetingResponseSuccess,
      onTasksClosed: onMeetingResponseSuccess,
      tasksOnly: tasksOnly,
    );
  }
}
