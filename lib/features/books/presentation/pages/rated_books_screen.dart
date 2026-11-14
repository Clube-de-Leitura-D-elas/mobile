import 'package:flutter/scheduler.dart';
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
    _checkScrollAndLoadMore();
  }

  /// Verifica se precisamos carregar mais dados, seja porque o usuário rolou
  /// até o final, ou porque o conteúdo não preencheu a tela.
  void _checkScrollAndLoadMore() {
    if (!_scrollController.hasClients) return;

    final state = context.read<RatedBooksCubit>().state;
    if (state is RatedBooksLoaded && state.loadMoreFailure != null) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    // Se maxScroll for 0, significa que o conteúdo não preencheu a tela
    // e não há rolagem possível. Neste caso, devemos tentar carregar mais.
    if (maxScroll == 0 || currentScroll >= maxScroll * 0.8) {
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
      // Usamos um listener no BlocConsumer/BlocListener para checar a rolagem
      // SEMPRE que o estado mudar para Loaded com sucesso.
      body: BlocConsumer<RatedBooksCubit, RatedBooksState>(
        listener: (context, state) {
          if (state is RatedBooksLoaded &&
              !state.isLoadingMore &&
              state.hasMore &&
              state.loadMoreFailure == null) {
            // Usamos addPostFrameCallback para garantir que a verificação de
            // maxScrollExtent aconteça DEPOIS que o ListView for renderizado na tela.
            SchedulerBinding.instance.addPostFrameCallback((_) {
              _checkScrollAndLoadMore();
            });
          }
        },
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
            RatedBooksLoaded(
              :final books,
              :final isLoadingMore,
              :final loadMoreFailure,
            ) =>
              RefreshIndicator(
                color: colors.actionPrimary,
                backgroundColor: colors.surfaceDefault,
                onRefresh: () => context.read<RatedBooksCubit>().refresh(),
                child: ListView.separated(
                  // Usar AlwaysScrollableScrollPhysics garante que o RefreshIndicator
                  // funcione mesmo quando a lista não preenche a tela.
                  physics: const AlwaysScrollableScrollPhysics(),
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.s16,
                    vertical: spacing.s8,
                  ),
                  itemCount:
                      books.length +
                      (isLoadingMore || loadMoreFailure != null ? 1 : 0),
                  separatorBuilder: (_, _) =>
                      Divider(color: colors.borderDefault, height: spacing.s16),
                  itemBuilder: (context, index) {
                    if (index >= books.length) {
                      if (loadMoreFailure != null) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: spacing.s16),
                          child: AppErrorState(
                            message: ratedBooksFailureMessage(
                              l10n,
                              loadMoreFailure,
                            ),
                            onRetry: () =>
                                context.read<RatedBooksCubit>().loadMore(),
                          ),
                        );
                      }
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
