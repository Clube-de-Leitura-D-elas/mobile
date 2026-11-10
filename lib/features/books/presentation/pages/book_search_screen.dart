import 'package:flutter/material.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/books/domain/entities/book_reading_status.dart';
import 'package:mobile/features/books/domain/entities/book_summary.dart';
import 'package:mobile/features/books/presentation/cubit/book_search_state.dart';
import 'package:mobile/features/books/presentation/widgets/book_list_tile.dart';
import 'package:mobile/features/books/presentation/widgets/book_search_skeleton.dart';

ReadingStatusChipState readingChipFor(BookReadingStatus? status) {
  return switch (status) {
    null => ReadingStatusChipState.markAsRead,
    BookReadingStatus.wantToRead => ReadingStatusChipState.wantToRead,
    BookReadingStatus.read => ReadingStatusChipState.read,
  };
}

class BookSearchScreen extends StatelessWidget {
  const BookSearchScreen({
    super.key,
    required this.state,
    required this.onQueryChanged,
    required this.onRetry,
    required this.onLoadMore,
    required this.onStatusTap,
  });

  final BookSearchState state;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onRetry;
  final VoidCallback onLoadMore;
  final ValueChanged<String> onStatusTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.spacing;
    final colors = context.colors;

    return Material(
      color: colors.bgDefault,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ScreenHeader.simple(title: l10n.bookSearchTitle),
          Padding(
            padding: EdgeInsets.fromLTRB(
              spacing.s16,
              spacing.s16,
              spacing.s16,
              0,
            ),
            child: AppSearchField(
              hintText: l10n.bookSearchHint,
              onChanged: onQueryChanged,
            ),
          ),
          Expanded(
            child: _BookSearchBody(
              state: state,
              onRetry: onRetry,
              onLoadMore: onLoadMore,
              onStatusTap: onStatusTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _BookSearchBody extends StatelessWidget {
  const _BookSearchBody({
    required this.state,
    required this.onRetry,
    required this.onLoadMore,
    required this.onStatusTap,
  });

  final BookSearchState state;
  final VoidCallback onRetry;
  final VoidCallback onLoadMore;
  final ValueChanged<String> onStatusTap;

  static const _loadMoreExtent = 400.0;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final colors = context.colors;
    final typography = context.typography;

    if (state.isLoading && state.books.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(spacing.s16),
        child: const BookSearchSkeleton(),
      );
    }
    if (state.hasError) {
      return _Message(onRetry: onRetry, isError: true);
    }
    if (state.isEmpty) {
      return const _Message();
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        final metrics = notification.metrics;
        if (metrics.extentAfter < _loadMoreExtent &&
            state.hasMore &&
            !state.isLoading &&
            !state.isLoadingMore &&
            !state.hasLoadMoreError) {
          onLoadMore();
        }
        return false;
      },
      child: CustomScrollView(
        slivers: [
          if (state.mode == BookSearchMode.popular) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  spacing.s16,
                  spacing.s24,
                  spacing.s16,
                  spacing.s16,
                ),
                child: Text(
                  context.l10n.bookSearchPopularTitle,
                  style: typography.headingH3.copyWith(
                    color: colors.textDefault,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: spacing.s16),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: spacing.s16,
                  crossAxisSpacing: spacing.s16,
                  childAspectRatio: 0.55,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _PopularCell(book: state.books[index]),
                  childCount: state.books.length,
                ),
              ),
            ),
          ] else
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                spacing.s16,
                spacing.s16,
                spacing.s16,
                0,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final book = state.books[index];
                  return Padding(
                    padding: EdgeInsets.only(bottom: spacing.s16),
                    child: BookListTile(
                      title: book.title,
                      author: book.author,
                      genre: book.genre,
                      imageUrl: book.coverUrl,
                      status: readingChipFor(book.myStatus),
                      isStatusLoading: state.updatingStatusIds.contains(
                        book.id,
                      ),
                      onStatusTap: () => onStatusTap(book.id),
                    ),
                  );
                }, childCount: state.books.length),
              ),
            ),
          if (state.hasLoadMoreError)
            SliverToBoxAdapter(
              child: _Message(onRetry: onRetry, isError: true),
            ),
          const SliverToBoxAdapter(child: Gap24()),
        ],
      ),
    );
  }
}

class _PopularCell extends StatelessWidget {
  const _PopularCell({required this.book});

  final BookSummary book;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: book.title,
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppBookCover(imageUrl: book.coverUrl, size: AppBookCoverSize.grid),
            const Gap8(),
            Text(
              book.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.typography.labelTag.copyWith(
                color: context.colors.textDefault,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({this.onRetry, this.isError = false});

  final VoidCallback? onRetry;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.spacing;

    return Padding(
      padding: EdgeInsets.all(spacing.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            liveRegion: isError,
            child: Text(
              isError ? l10n.bookSearchLoadError : l10n.bookSearchEmpty,
              style: context.typography.bodyDefault.copyWith(
                color: context.colors.textMuted,
              ),
            ),
          ),
          if (onRetry != null) ...[
            const Gap12(),
            AppButton.secondary(
              label: l10n.bookSearchRetry,
              size: AppButtonSize.lg,
              onPressed: onRetry,
            ),
          ],
        ],
      ),
    );
  }
}
