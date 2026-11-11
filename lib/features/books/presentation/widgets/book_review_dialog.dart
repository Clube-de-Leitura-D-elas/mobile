import 'package:flutter/material.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/books/domain/entities/book_review_entity.dart';

/// Envia a avaliação e diz se deu certo.
typedef BookReviewSubmit =
    Future<bool> Function({required int rating, String? commentary});

Future<void> showBookReviewDialog(
  BuildContext context, {
  required BookReviewSubmit onSubmit,
  MyBookReviewEntity? initialReview,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) =>
        BookReviewDialog(onSubmit: onSubmit, initialReview: initialReview),
  );
}

class BookReviewDialog extends StatefulWidget {
  const BookReviewDialog({
    super.key,
    required this.onSubmit,
    this.initialReview,
  });

  /// Limite da upsert-book-review, contado em caracteres visíveis.
  static const int maxCommentaryLength = 1000;

  final BookReviewSubmit onSubmit;
  final MyBookReviewEntity? initialReview;

  @override
  State<BookReviewDialog> createState() => _BookReviewDialogState();
}

class _BookReviewDialogState extends State<BookReviewDialog> {
  late int _rating = widget.initialReview?.rating ?? 0;
  late final TextEditingController _commentary = TextEditingController(
    text: widget.initialReview?.commentary ?? '',
  );
  bool _isSaving = false;

  bool get _isCommentaryTooLong =>
      _commentary.text.trim().characters.length >
      BookReviewDialog.maxCommentaryLength;

  bool get _canSave => _rating > 0 && !_isCommentaryTooLong && !_isSaving;

  @override
  void dispose() {
    _commentary.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final commentary = _commentary.text.trim();
    final saved = await widget.onSubmit(
      rating: _rating,
      commentary: commentary.isEmpty ? null : commentary,
    );
    if (!mounted) return;

    if (saved) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _isSaving = false);
    context.showErrorToast(context.l10n.bookReviewSaveError);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final typography = context.typography;

    return AppDialog(
      title: widget.initialReview == null
          ? l10n.bookReviewDialogTitle
          : l10n.bookReviewDialogEditTitle,
      // Fechar no meio do envio deixaria a resposta sem tela para mostrar.
      onClose: _isSaving ? () {} : null,
      actions: [
        AppButton.primary(
          label: l10n.bookReviewSaveButton,
          size: AppButtonSize.lg,
          isLoading: _isSaving,
          onPressed: _canSave ? _save : null,
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.bookReviewRatingLabel,
            style: typography.bodyDefaultEmphasis.copyWith(
              color: colors.textDefault,
            ),
          ),
          const Gap8(),
          AppStarRating.input(
            rating: _rating,
            onChanged: _isSaving
                ? null
                : (rating) => setState(() => _rating = rating),
          ),
          const Gap16(),
          AppTextField(
            label: l10n.bookReviewCommentaryLabel,
            controller: _commentary,
            maxLines: 4,
            enabled: !_isSaving,
            errorText: _isCommentaryTooLong
                ? l10n.bookReviewCommentaryTooLong(
                    BookReviewDialog.maxCommentaryLength,
                  )
                : null,
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }
}
