import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
              _BookListMetaAndChip(
                spacing: spacing.s8,
                hasMeta: hasMeta,
                onTap: onTap,
                chip: status == null
                    ? null
                    : AppReadingStatusChip(
                        state: status,
                        onTap: onStatusTap,
                        isLoading: isStatusLoading,
                      ),
                meta: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (author.isNotEmpty)
                      Text(
                        author,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: typography.bodySmallEmphasis.copyWith(
                          color: colors.textMuted,
                        ),
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
            ],
          ),
        ),
      ],
    );
  }
}

/// Autor, gênero e chip. O chip desce de linha quando não sobra ao menos
/// [BookListTile.hitHeight] ao lado dele. O toque do bloco fica fora da
/// árvore semântica: o rótulo já está no título.
class _BookListMetaAndChip extends MultiChildRenderObjectWidget {
  _BookListMetaAndChip({
    required Widget meta,
    required Widget? chip,
    required this.spacing,
    required this.hasMeta,
    required VoidCallback? onTap,
  }) : hasChip = chip != null,
       super(
         children: [
           ?chip,
           InkWell(
             excludeFromSemantics: true,
             onTap: onTap,
             child: ExcludeSemantics(
               child: ConstrainedBox(
                 constraints: BoxConstraints(
                   minHeight: hasMeta ? BookListTile.hitHeight : 0,
                 ),
                 child: meta,
               ),
             ),
           ),
         ],
       );

  final double spacing;
  final bool hasMeta;
  final bool hasChip;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderBookListMetaAndChip(
      spacing: spacing,
      hasChip: hasChip,
      reserveMetaWidth: hasMeta,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderBookListMetaAndChip renderObject,
  ) {
    renderObject
      ..spacing = spacing
      ..hasChip = hasChip
      ..reserveMetaWidth = hasMeta;
  }
}

class _BookListMetaAndChipParentData
    extends ContainerBoxParentData<RenderBox> {}

class _RenderBookListMetaAndChip extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _BookListMetaAndChipParentData>,
        RenderBoxContainerDefaultsMixin<
          RenderBox,
          _BookListMetaAndChipParentData
        > {
  _RenderBookListMetaAndChip({
    required double spacing,
    required bool hasChip,
    required bool reserveMetaWidth,
  }) : _spacing = spacing,
       _hasChip = hasChip,
       _reserveMetaWidth = reserveMetaWidth;

  double _spacing;
  double get spacing => _spacing;
  set spacing(double value) {
    if (_spacing == value) return;
    _spacing = value;
    markNeedsLayout();
  }

  bool _hasChip;
  bool get hasChip => _hasChip;
  set hasChip(bool value) {
    if (_hasChip == value) return;
    _hasChip = value;
    markNeedsLayout();
  }

  bool _reserveMetaWidth;
  bool get reserveMetaWidth => _reserveMetaWidth;
  set reserveMetaWidth(bool value) {
    if (_reserveMetaWidth == value) return;
    _reserveMetaWidth = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _BookListMetaAndChipParentData) {
      child.parentData = _BookListMetaAndChipParentData();
    }
  }

  bool _sharesLine(double maxWidth, double chipWidth) {
    final reserved = reserveMetaWidth ? BookListTile.hitHeight : 0;
    final gap = reserveMetaWidth ? spacing : 0;
    return chipWidth + gap + reserved <= maxWidth;
  }

  @override
  void performLayout() {
    final maxWidth = constraints.maxWidth;
    final first = firstChild!;
    if (!hasChip) {
      first.layout(BoxConstraints(maxWidth: maxWidth), parentUsesSize: true);
      (first.parentData! as _BookListMetaAndChipParentData).offset =
          Offset.zero;
      size = constraints.constrain(Size(maxWidth, first.size.height));
      return;
    }

    final meta = childAfter(first)!;
    first.layout(BoxConstraints(maxWidth: maxWidth), parentUsesSize: true);
    final sharesLine = _sharesLine(maxWidth, first.size.width);
    final gap = sharesLine && reserveMetaWidth ? spacing : 0.0;
    final metaWidth = math.max(
      0.0,
      sharesLine ? maxWidth - first.size.width - gap : maxWidth,
    );
    meta.layout(
      BoxConstraints.tightFor(width: metaWidth),
      parentUsesSize: true,
    );

    if (sharesLine) {
      final double height = math.max(first.size.height, meta.size.height);
      (meta.parentData! as _BookListMetaAndChipParentData).offset = Offset(
        0,
        height - meta.size.height,
      );
      (first.parentData! as _BookListMetaAndChipParentData).offset = Offset(
        maxWidth - first.size.width,
        height - first.size.height,
      );
      size = constraints.constrain(Size(maxWidth, height));
      return;
    }

    (meta.parentData! as _BookListMetaAndChipParentData).offset = Offset.zero;
    (first.parentData! as _BookListMetaAndChipParentData).offset = Offset(
      0,
      meta.size.height + spacing,
    );
    size = constraints.constrain(
      Size(maxWidth, meta.size.height + spacing + first.size.height),
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}
