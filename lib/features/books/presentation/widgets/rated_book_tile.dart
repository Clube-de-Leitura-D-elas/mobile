import 'package:material_ui/material_ui.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/books/domain/entities/rated_book.dart';

/// Tile de livro avaliado na lista: capa, título, autora, estrelas e comentário.
class RatedBookTile extends StatelessWidget {
  final RatedBook book;
  final VoidCallback? onTap;

  const RatedBookTile({
    super.key,
    required this.book,
    this.onTap,
  });

  String _buildSemanticLabel() {
    final ratingFormatted = book.rating == book.rating.floorToDouble()
        ? book.rating.toInt().toString()
        : book.rating.toStringAsFixed(1).replaceAll('.', ',');

    final parts = [
      book.title,
      if (book.author.isNotEmpty) 'escrito por ${book.author}',
      'avaliado com $ratingFormatted de 5 estrelas',
      if (book.comment != null && book.comment!.isNotEmpty)
        'comentário: ${book.comment}',
    ];
    return parts.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;
    final hasComment = book.comment != null && book.comment!.trim().isNotEmpty;

    return Semantics(
      container: true,
      button: onTap != null,
      enabled: onTap != null,
      label: _buildSemanticLabel(),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(spacing.s8),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: spacing.s8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ExcludeSemantics(
                child: AppBookCover(
                  imageUrl: book.coverUrl,
                  size: AppBookCoverSize.list,
                ),
              ),
              SizedBox(width: spacing.s16),
              Expanded(
                child: ExcludeSemantics(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        book.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: typography.headingH3.copyWith(
                          color: colors.textDefault,
                        ),
                      ),
                      if (book.author.isNotEmpty) ...[
                        SizedBox(height: spacing.s4),
                        Text(
                          book.author,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: typography.bodySmallEmphasis.copyWith(
                            color: colors.textMuted,
                          ),
                        ),
                      ],
                      SizedBox(height: spacing.s8),
                      AppStarRating.display(
                        rating: book.rating,
                        size: AppStarRatingSize.sm,
                      ),
                      if (hasComment) ...[
                        SizedBox(height: spacing.s8),
                        Text(
                          book.comment!,
                          style: typography.bodySmall.copyWith(
                            color: colors.textDefault,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
