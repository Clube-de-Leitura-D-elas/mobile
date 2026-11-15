import 'package:material_ui/material_ui.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/profile/domain/entities/profile_summary_entity.dart';

/// Capas dos últimos livros avaliados, em linha, com o título embaixo.
class ProfileReviewedBooks extends StatelessWidget {
  const ProfileReviewedBooks({
    super.key,
    required this.books,
    required this.onBookTap,
  });

  final List<ProfileReviewedBookEntity> books;
  final ValueChanged<String> onBookTap;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (index, book) in books.indexed) ...[
            if (index > 0) SizedBox(width: spacing.s16),
            _ReviewedBook(book: book, onTap: () => onBookTap(book.bookId)),
          ],
        ],
      ),
    );
  }
}

class _ReviewedBook extends StatelessWidget {
  const _ReviewedBook({required this.book, required this.onTap});

  final ProfileReviewedBookEntity book;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return Semantics(
      container: true,
      button: true,
      label: book.title,
      onTap: onTap,
      child: InkWell(
        key: ValueKey('profile-book-${book.bookId}'),
        excludeFromSemantics: true,
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppBookCover.borderRadius),
        child: ExcludeSemantics(
          child: SizedBox(
            width: AppBookCover.headerSize.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppBookCover(
                  imageUrl: book.coverUrl,
                  size: AppBookCoverSize.header,
                ),
                SizedBox(height: spacing.s8),
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
        ),
      ),
    );
  }
}
