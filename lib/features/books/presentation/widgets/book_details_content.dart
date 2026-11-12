import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/books/domain/entities/book_details_entity.dart';
import 'package:mobile/features/books/domain/entities/book_reading_status.dart';
import 'package:mobile/features/books/presentation/cubit/book_details_cubit.dart';
import 'package:mobile/features/books/presentation/cubit/book_details_state.dart';
import 'package:mobile/features/books/presentation/widgets/book_detail_header.dart';
import 'package:mobile/features/books/presentation/widgets/book_review_tile.dart';

class BookDetailsContent extends StatelessWidget {
  const BookDetailsContent({super.key, required this.state});

  final BookDetailsState state;

  static ReadingStatusChipState chipStateFor(BookReadingStatus? status) {
    return switch (status) {
      BookReadingStatus.read => ReadingStatusChipState.read,
      BookReadingStatus.wantToRead => ReadingStatusChipState.wantToRead,
      null => ReadingStatusChipState.markAsRead,
    };
  }

  @override
  Widget build(BuildContext context) {
    final details = state.details!;
    final spacing = context.spacing;
    final cubit = context.read<BookDetailsCubit>();
    final reviews = state.reviews;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: BookDetailHeader(
            title: details.title,
            author: details.author,
            coverUrl: details.coverUrl,
            rating: details.ratingAverage,
            status: chipStateFor(details.myStatus),
            onStatusTap: cubit.toggleReadingStatus,
            isStatusLoading: state.isUpdatingStatus,
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            spacing.s16,
            spacing.s24,
            spacing.s16,
            0,
          ),
          sliver: SliverList.list(
            children: [
              _BookActions(details: details),
              ..._synopsis(context, details.synopsis),
              SizedBox(height: spacing.s24),
              _SectionTitle(context.l10n.bookDetailReviewsTitle),
              SizedBox(height: spacing.s12),
              if (reviews.isEmpty)
                Text(
                  context.l10n.bookDetailNoReviews,
                  style: context.typography.bodyDefault.copyWith(
                    color: context.colors.textMuted,
                  ),
                ),
            ],
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            spacing.s16,
            0,
            spacing.s16,
            spacing.s24,
          ),
          sliver: SliverList.separated(
            itemCount: reviews.length + (state.hasMoreReviews ? 1 : 0),
            separatorBuilder: (_, _) => SizedBox(height: spacing.s16),
            itemBuilder: (context, index) {
              if (index < reviews.length) {
                final review = reviews[index];
                return BookReviewTile(
                  key: ValueKey('book-review-${review.id}'),
                  name: review.userName,
                  photoUrl: review.userPhotoUrl,
                  rating: review.rating.toDouble(),
                  comment: review.commentary ?? '',
                );
              }
              if (state.loadMoreReviewsFailed) {
                return _LoadMoreReviewsError(onRetry: cubit.loadMoreReviews);
              }
              return _LoadMoreReviewsTrigger(
                key: ValueKey(state.reviewsPage),
                onVisible: cubit.loadMoreReviews,
              );
            },
          ),
        ),
      ],
    );
  }

  List<Widget> _synopsis(BuildContext context, String? synopsis) {
    final text = synopsis?.trim() ?? '';
    final colors = context.colors;

    return [
      SizedBox(height: context.spacing.s24),
      _SectionTitle(context.l10n.bookDetailSynopsisTitle),
      SizedBox(height: context.spacing.s8),
      Text(
        text.isEmpty ? context.l10n.bookDetailNoSynopsis : text,
        style: context.typography.bodyDefault.copyWith(
          color: text.isEmpty ? colors.textMuted : colors.textDefault,
        ),
      ),
    ];
  }
}

class _BookActions extends StatelessWidget {
  const _BookActions({required this.details});

  final BookDetailsEntity details;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Row(
      children: [
        Expanded(
          // TODO(CLU-271): abrir o modal Avaliar livro (upsert-book-review).
          child: AppButton.secondary(
            label: details.myReview == null
                ? l10n.bookDetailRateButton
                : l10n.bookDetailEditReviewButton,
            size: AppButtonSize.lg,
            onPressed: null,
          ),
        ),
        SizedBox(width: context.spacing.s16),
        Expanded(
          // TODO(CLU-272): abrir o modal Selecione o grupo (recommend-book).
          child: AppButton.primary(
            label: l10n.bookDetailRecommendButton,
            size: AppButtonSize.lg,
            onPressed: null,
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(
        text,
        style: context.typography.bodySmall.copyWith(
          color: context.colors.textMuted,
        ),
      ),
    );
  }
}

class _LoadMoreReviewsError extends StatelessWidget {
  const _LoadMoreReviewsError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Semantics(
          liveRegion: true,
          child: Text(
            context.l10n.bookDetailLoadMoreReviewsError,
            style: context.typography.bodyDefault.copyWith(
              color: context.colors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
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

/// Fim da lista: o sliver só constrói este item quando ele se aproxima da tela.
class _LoadMoreReviewsTrigger extends StatefulWidget {
  const _LoadMoreReviewsTrigger({super.key, required this.onVisible});

  final VoidCallback onVisible;

  @override
  State<_LoadMoreReviewsTrigger> createState() =>
      _LoadMoreReviewsTriggerState();
}

class _LoadMoreReviewsTriggerState extends State<_LoadMoreReviewsTrigger> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onVisible();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Semantics(
        label: context.l10n.bookDetailLoadingMoreReviews,
        child: CircularProgressIndicator(color: context.colors.actionPrimary),
      ),
    );
  }
}
