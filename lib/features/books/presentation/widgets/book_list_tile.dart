import 'package:flutter/material.dart';
import 'package:mobile/design_system/design_system.dart';

/// Item da lista de resultados: capa, título, autor, gênero e chip de status.
///
/// O toque na linha e o toque no chip são separados. Sem [status] o chip
/// não aparece. "Marcar como lido" é um estado do chip, distinto de
/// "Já lido" e "Quero ler".
class BookListTile extends StatelessWidget {
  const BookListTile({
    super.key,
    required this.title,
    required this.author,
    required this.genre,
    this.imageUrl,
    this.status,
    this.onTap,
    this.onStatusTap,
    this.isStatusLoading = false,
  });

  final String? imageUrl;
  final String title;
  final String author;
  final String genre;
  final ReadingStatusChipState? status;
  final VoidCallback? onTap;
  final VoidCallback? onStatusTap;
  final bool isStatusLoading;

  /// Altura mínima do toque no título e no bloco de autor e gênero.
  static const double hitHeight = 48;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;
    final status = this.status;
    final hasMeta = author.isNotEmpty || genre.isNotEmpty;
    final label = [
      title,
      if (author.isNotEmpty) author,
      if (genre.isNotEmpty) genre,
    ].join(', ');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ExcludeSemantics(
          child: InkWell(
            onTap: onTap,
            child: AppBookCover(imageUrl: imageUrl),
          ),
        ),
        SizedBox(width: spacing.s16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                button: onTap != null,
                enabled: onTap != null,
                label: label,
                child: InkWell(
                  onTap: onTap,
                  child: ExcludeSemantics(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: hitHeight),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: typography.headingH3.copyWith(
                            color: colors.textDefault,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: spacing.s8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: onTap,
                      child: ExcludeSemantics(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: hasMeta ? hitHeight : 0,
                          ),
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (author.isNotEmpty)
                                  Text(
                                    author,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: typography.bodySmallEmphasis
                                        .copyWith(color: colors.textMuted),
                                  ),
                                if (genre.isNotEmpty)
                                  Text(
                                    genre,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: typography.labelTag.copyWith(
                                      color: colors.textMuted,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (status != null) ...[
                    SizedBox(width: spacing.s8),
                    AppReadingStatusChip(
                      state: status,
                      onTap: onStatusTap,
                      isLoading: isStatusLoading,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
