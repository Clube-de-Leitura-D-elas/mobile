import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';

/// Comentário de avaliação limitado a [collapsedMaxLines] linhas, com
/// "Ver mais"/"Ver menos" só quando o texto passa do limite.
class BookReviewComment extends StatefulWidget {
  const BookReviewComment(this.text, {super.key});

  static const int collapsedMaxLines = 4;

  final String text;

  @override
  State<BookReviewComment> createState() => _BookReviewCommentState();
}

class _BookReviewCommentState extends State<BookReviewComment> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final style = DefaultTextStyle.of(
      context,
    ).style.merge(typography.bodySmall.copyWith(color: colors.textDefault));

    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: TextSpan(text: widget.text, style: style),
          maxLines: BookReviewComment.collapsedMaxLines,
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
          locale: Localizations.maybeLocaleOf(context),
          textHeightBehavior: DefaultTextHeightBehavior.maybeOf(context),
        )..layout(maxWidth: constraints.maxWidth);
        final overflows = painter.didExceedMaxLines;
        painter.dispose();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.text,
              style: style,
              maxLines: _expanded || !overflows
                  ? null
                  : BookReviewComment.collapsedMaxLines,
              overflow: _expanded || !overflows
                  ? TextOverflow.clip
                  : TextOverflow.ellipsis,
            ),
            if (overflows)
              Semantics(
                button: true,
                expanded: _expanded,
                child: InkWell(
                  onTap: () => setState(() => _expanded = !_expanded),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minHeight: 48,
                      minWidth: 48,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      widthFactor: 1,
                      child: Text(
                        _expanded
                            ? context.l10n.bookReviewCommentShowLess
                            : context.l10n.bookReviewCommentShowMore,
                        style: typography.bodySmallEmphasis.copyWith(
                          color: colors.actionPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
