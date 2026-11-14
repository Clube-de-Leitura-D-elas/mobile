import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/books/domain/entities/book_review_entity.dart';
import 'package:mobile/features/books/presentation/cubit/book_details_cubit.dart';
import 'package:mobile/features/books/presentation/cubit/book_details_state.dart';

class BookReviewDialog extends StatefulWidget {
  const BookReviewDialog({super.key, this.review});

  final MyBookReviewEntity? review;

  static Future<bool?> show(
    BuildContext context, {
    MyBookReviewEntity? review,
  }) {
    final cubit = context.read<BookDetailsCubit>();
    return showDialog<bool>(
      context: context,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: BookReviewDialog(review: review),
      ),
    );
  }

  @override
  State<BookReviewDialog> createState() => _BookReviewDialogState();
}

class _BookReviewDialogState extends State<BookReviewDialog> {
  late int _rating;
  late String _commentary;

  @override
  void initState() {
    super.initState();
    _rating = widget.review?.rating ?? 0;
    _commentary = widget.review?.commentary ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final navigator = Navigator.of(context);

    return BlocBuilder<BookDetailsCubit, BookDetailsState>(
      builder: (context, state) {
        final isSubmitting = state.isSubmittingReview;
        return AppDialog(
          title: l10n.bookReviewDialogTitle,
          onClose: () {
            if (!isSubmitting) {
              navigator.pop(false);
            }
          },
          actions: [
            AppButton.secondary(
              label: l10n.bookReviewCancel,
              size: AppButtonSize.lg,
              onPressed: isSubmitting ? null : () => navigator.pop(false),
            ),
            AppButton.primary(
              label: l10n.bookReviewSubmit,
              size: AppButtonSize.lg,
              isLoading: isSubmitting,
              onPressed: _rating == 0
                  ? null
                  : () async {
                      final saved = await context
                          .read<BookDetailsCubit>()
                          .upsertBookReview(
                            rating: _rating,
                            commentary: _commentary.trim().isEmpty
                                ? null
                                : _commentary.trim(),
                          );
                      if (saved && mounted) navigator.pop(true);
                    },
            ),
          ],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.bookReviewRatingLabel,
                style: context.typography.bodySmall.copyWith(
                  color: context.colors.textDefault,
                ),
              ),
              const Gap8(),
              Center(
                child: AppStarRating.input(
                  rating: _rating,
                  emptyColor: context.colors.textMuted,
                  onChanged: isSubmitting
                      ? null
                      : (rating) => setState(() => _rating = rating),
                ),
              ),
              const Gap16(),
              AppTextField(
                label: l10n.bookReviewCommentLabel,
                hintText: l10n.bookReviewCommentHint,
                initialValue: _commentary,
                maxLines: 6,
                keyboardType: TextInputType.multiline,
                inputFormatters: [LengthLimitingTextInputFormatter(1000)],
                enabled: !isSubmitting,
                onChanged: (value) => _commentary = value,
              ),
            ],
          ),
        );
      },
    );
  }
}
