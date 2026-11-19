import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/books/domain/entities/book_recommendation_group.dart';
import 'package:mobile/features/books/presentation/cubit/book_details_cubit.dart';
import 'package:mobile/features/books/presentation/cubit/book_details_state.dart';
import 'package:mobile/features/books/presentation/widgets/group_select_tile.dart';

class BookRecommendationDialog extends StatelessWidget {
  const BookRecommendationDialog({super.key});

  static Future<void> show(BuildContext context) {
    final cubit = context.read<BookDetailsCubit>();
    unawaited(cubit.loadRecommendationGroups());
    return showDialog<void>(
      context: context,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: const BookRecommendationDialog(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookDetailsCubit, BookDetailsState>(
      buildWhen: (previous, current) =>
          previous.recommendationGroupsStatus !=
              current.recommendationGroupsStatus ||
          previous.recommendationGroups != current.recommendationGroups ||
          previous.isRecommending != current.isRecommending,
      builder: (context, state) {
        return PopScope(
          canPop: !state.isRecommending,
          child: AppDialog(
            title: context.l10n.bookRecommendationGroupsTitle,
            onClose: () {
              if (!state.isRecommending) {
                Navigator.of(context).pop();
              }
            },
            child: switch (state.recommendationGroupsStatus) {
              RecommendationGroupsStatus.idle ||
              RecommendationGroupsStatus.loading =>
                const _RecommendationGroupsLoading(),
              RecommendationGroupsStatus.error => _RecommendationGroupsError(
                onRetry: context
                    .read<BookDetailsCubit>()
                    .loadRecommendationGroups,
              ),
              RecommendationGroupsStatus.loaded =>
                state.recommendationGroups.isEmpty
                    ? const _RecommendationGroupsEmpty()
                    : _RecommendationGroupsList(
                        groups: state.recommendationGroups,
                        isRecommending: state.isRecommending,
                      ),
            },
          ),
        );
      },
    );
  }
}

class _RecommendationGroupsLoading extends StatelessWidget {
  const _RecommendationGroupsLoading();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.spacing.s24),
      child: Center(
        child: Semantics(
          label: context.l10n.groupSearchLoading,
          child: CircularProgressIndicator(color: context.colors.actionPrimary),
        ),
      ),
    );
  }
}

class _RecommendationGroupsError extends StatelessWidget {
  const _RecommendationGroupsError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          context.l10n.bookRecommendationGroupsError,
          style: context.typography.bodyDefault.copyWith(
            color: context.colors.textMuted,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: context.spacing.s16),
        AppButton.secondary(
          label: context.l10n.errorRetryButton,
          size: AppButtonSize.lg,
          onPressed: onRetry,
        ),
      ],
    );
  }
}

class _RecommendationGroupsEmpty extends StatelessWidget {
  const _RecommendationGroupsEmpty();

  @override
  Widget build(BuildContext context) {
    return Text(
      context.l10n.bookRecommendationGroupsEmpty,
      style: context.typography.bodyDefault.copyWith(
        color: context.colors.textMuted,
      ),
    );
  }
}

class _RecommendationGroupsList extends StatelessWidget {
  const _RecommendationGroupsList({
    required this.groups,
    required this.isRecommending,
  });

  final List<BookRecommendationGroup> groups;
  final bool isRecommending;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < groups.length; index++) ...[
          if (index > 0) SizedBox(height: context.spacing.s16),
          _RecommendationGroupTile(
            group: groups[index],
            isRecommending: isRecommending,
          ),
        ],
      ],
    );
  }
}

class _RecommendationGroupTile extends StatelessWidget {
  const _RecommendationGroupTile({
    required this.group,
    required this.isRecommending,
  });

  final BookRecommendationGroup group;
  final bool isRecommending;

  @override
  Widget build(BuildContext context) {
    final displayName = group.number != null
        ? context.l10n.groupNameLabel(group.number!)
        : group.name;

    return GroupSelectTile(
      key: ValueKey(group.id),
      name: displayName,
      photoUrl: group.photoUrl,
      alreadySuggested: group.alreadyRecommended,
      onTap: isRecommending
          ? null
          : () async {
              final recommended = await context
                  .read<BookDetailsCubit>()
                  .recommendBook(groupId: group.id, groupName: displayName);
              if (recommended && context.mounted) {
                Navigator.of(context).pop();
              }
            },
    );
  }
}
