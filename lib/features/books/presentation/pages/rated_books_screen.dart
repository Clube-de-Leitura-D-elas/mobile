import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/books/domain/entities/rated_book.dart';
import 'package:mobile/features/books/presentation/book_failure_message.dart';
import 'package:mobile/features/books/presentation/cubit/rated_books_cubit.dart';
import 'package:mobile/features/books/presentation/cubit/rated_books_state.dart';
import 'package:mobile/features/books/presentation/widgets/rated_book_tile.dart';

class RatedBooksScreen extends StatefulWidget {
  final ValueChanged<RatedBook>? onBookTap;

  const RatedBooksScreen({super.key, this.onBookTap});

  @override
  State<RatedBooksScreen> createState() => _RatedBooksScreenState();
}

class _RatedBooksScreenState extends State<RatedBooksScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (currentScroll >= maxScroll * 0.8) {
      context.read<RatedBooksCubit>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final spacing = context.spacing;
    final typography = context.typography;

    return Scaffold(
      backgroundColor: colors.bgDefault,
      appBar: ScreenHeader.back(title: l10n.ratedBooksTitle),
      body: BlocBuilder<RatedBooksCubit, RatedBooksState>(
        builder: (context, state) {
          return switch (state) {
            RatedBooksInitial() || RatedBooksLoading() => Center(
              child: Semantics(
                label: l10n.ratedBooksLoading,
                child: CircularProgressIndicator(color: colors.actionPrimary),
              ),
            ),
            RatedBooksEmpty() => Center(
              child: Padding(
                padding: EdgeInsets.all(spacing.s24),
                child: Text(
                  l10n.noRatedBooksMessage,
                  textAlign: TextAlign.center,
                  style: typography.bodyDefault.copyWith(
                    color: colors.textMuted,
                  ),
                ),
              ),
            ),
            RatedBooksError(:final failure) => AppErrorState(
              message: ratedBooksFailureMessage(l10n, failure),
              onRetry: () => context.read<RatedBooksCubit>().refresh(),
            ),
            RatedBooksLoaded(:final books, :final isLoadingMore) =>
              RefreshIndicator(
                color: colors.actionPrimary,
                backgroundColor: colors.surfaceDefault,
                onRefresh: () => context.read<RatedBooksCubit>().refresh(),
                child: ListView.separated(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.s16,
                    vertical: spacing.s8,
                  ),
                  itemCount: books.length + (isLoadingMore ? 1 : 0),
                  separatorBuilder: (_, _) =>
                      Divider(color: colors.borderDefault, height: spacing.s16),
                  itemBuilder: (context, index) {
                    if (index >= books.length) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: spacing.s16),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: colors.actionPrimary,
                          ),
                        ),
                      );
                    }

                    final book = books[index];
                    return RatedBookTile(
                      book: book,
                      onTap: () => widget.onBookTap?.call(book),
                    );
                  },
                ),
              ),
          };
        },
      ),
    );
  }
}
