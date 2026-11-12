import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';
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

  /// Altura mínima do bloco de título e do bloco de autor e gênero.
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

    return Semantics(
      container: true,
      explicitChildNodes: true,
      button: onTap != null,
      enabled: onTap != null ? true : null,
      label: label,
      onTap: onTap,
      child: InkWell(
        excludeFromSemantics: true,
        onTap: onTap,
        child: _BookListLine(
          gap: spacing.s16,
          cover: ExcludeSemantics(child: AppBookCover(imageUrl: imageUrl)),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ExcludeSemantics(
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
              SizedBox(height: spacing.s8),
              _BookListMetaAndChip(
                spacing: spacing.s8,
                hasMeta: hasMeta,
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
      ),
    );
  }
}

/// Capa e texto no topo. Com largura finita o texto ocupa o que sobra;
/// sem largura limitada a linha encolhe no conteúdo.
class _BookListLine extends MultiChildRenderObjectWidget {
  _BookListLine({
    required this.gap,
    required Widget cover,
    required Widget body,
  }) : super(children: [cover, body]);

  final double gap;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderBookListLine(gap: gap);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderBookListLine renderObject,
  ) {
    renderObject.gap = gap;
  }
}

class _ChildOffset extends ContainerBoxParentData<RenderBox> {}

class _RenderBookListLine extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _ChildOffset>,
        RenderBoxContainerDefaultsMixin<RenderBox, _ChildOffset> {
  _RenderBookListLine({required double gap}) : _gap = gap;

  double _gap;
  double get gap => _gap;
  set gap(double value) {
    _gap = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _ChildOffset) {
      child.parentData = _ChildOffset();
    }
  }

  Size _layout({
    required BoxConstraints constraints,
    required Size Function(RenderBox child, BoxConstraints constraints) measure,
    void Function(RenderBox child, Offset offset)? place,
  }) {
    final cover = firstChild!;
    final body = childAfter(cover)!;
    final maxWidth = constraints.maxWidth;
    final coverSize = measure(
      cover,
      maxWidth.isFinite
          ? BoxConstraints(maxWidth: maxWidth)
          : const BoxConstraints(),
    );
    final double bodyWidth = maxWidth.isFinite
        ? math.max(0.0, maxWidth - coverSize.width - gap)
        : body.getMaxIntrinsicWidth(double.infinity);
    final bodySize = measure(body, BoxConstraints.tightFor(width: bodyWidth));
    final double height = math.max(coverSize.height, bodySize.height);
    place?.call(cover, Offset.zero);
    place?.call(body, Offset(coverSize.width + gap, 0));
    final width = maxWidth.isFinite
        ? maxWidth
        : coverSize.width + gap + bodySize.width;
    return constraints.constrain(Size(width, height));
  }

  @override
  void performLayout() {
    size = _layout(
      constraints: constraints,
      measure: (child, childConstraints) {
        child.layout(childConstraints, parentUsesSize: true);
        return child.size;
      },
      place: (child, offset) {
        (child.parentData! as _ChildOffset).offset = offset;
      },
    );
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return _layout(
      constraints: constraints,
      measure: (child, childConstraints) =>
          child.getDryLayout(childConstraints),
    );
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return getDryLayout(BoxConstraints(maxWidth: width)).height;
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}

/// Autor, gênero e chip. O chip desce de linha quando não sobra ao menos
/// [BookListTile.hitHeight] ao lado dele.
class _BookListMetaAndChip extends MultiChildRenderObjectWidget {
  _BookListMetaAndChip({
    required Widget meta,
    required Widget? chip,
    required this.spacing,
    required this.hasMeta,
  }) : hasChip = chip != null,
       super(
         children: [
           ?chip,
           ExcludeSemantics(
             child: ConstrainedBox(
               constraints: BoxConstraints(
                 minHeight: hasMeta ? BookListTile.hitHeight : 0,
               ),
               child: meta,
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

class _RenderBookListMetaAndChip extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _ChildOffset>,
        RenderBoxContainerDefaultsMixin<RenderBox, _ChildOffset> {
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
    if (child.parentData is! _ChildOffset) {
      child.parentData = _ChildOffset();
    }
  }

  bool _sharesLine(double maxWidth, double chipWidth) {
    final reserved = reserveMetaWidth ? BookListTile.hitHeight : 0;
    final gap = reserveMetaWidth ? spacing : 0;
    return chipWidth + gap + reserved <= maxWidth;
  }

  Size _layout({
    required BoxConstraints constraints,
    required Size Function(RenderBox child, BoxConstraints constraints) measure,
    void Function(RenderBox child, Offset offset)? place,
  }) {
    final maxWidth = constraints.maxWidth;
    final first = firstChild!;
    if (!maxWidth.isFinite) {
      return _layoutUnbounded(constraints: constraints, measure: measure);
    }

    if (!hasChip) {
      final firstSize = measure(first, BoxConstraints(maxWidth: maxWidth));
      place?.call(first, Offset.zero);
      return constraints.constrain(Size(maxWidth, firstSize.height));
    }

    final meta = childAfter(first)!;
    final chipSize = measure(first, BoxConstraints(maxWidth: maxWidth));
    final sharesLine = _sharesLine(maxWidth, chipSize.width);
    final gap = sharesLine && reserveMetaWidth ? spacing : 0.0;
    final metaWidth = math.max(
      0.0,
      sharesLine ? maxWidth - chipSize.width - gap : maxWidth,
    );
    final metaSize = measure(meta, BoxConstraints.tightFor(width: metaWidth));
    if (sharesLine) {
      final double height = math.max(chipSize.height, metaSize.height);
      place?.call(meta, Offset(0, height - metaSize.height));
      place?.call(
        first,
        Offset(maxWidth - chipSize.width, height - chipSize.height),
      );
      return constraints.constrain(Size(maxWidth, height));
    }

    place?.call(meta, Offset.zero);
    place?.call(first, Offset(0, metaSize.height + spacing));
    return constraints.constrain(
      Size(maxWidth, metaSize.height + spacing + chipSize.height),
    );
  }

  /// Sem largura máxima o chip não cabe numa conta com infinito.
  /// A linha encolhe na soma do texto e do chip.
  Size _layoutUnbounded({
    required BoxConstraints constraints,
    required Size Function(RenderBox child, BoxConstraints constraints) measure,
  }) {
    final first = firstChild!;
    if (!hasChip) {
      return constraints.constrain(measure(first, const BoxConstraints()));
    }

    final meta = childAfter(first)!;
    final chipSize = measure(first, const BoxConstraints());
    final metaSize = measure(meta, const BoxConstraints());
    final gap = reserveMetaWidth ? spacing : 0.0;
    final double height = math.max(chipSize.height, metaSize.height);
    return constraints.constrain(
      Size(metaSize.width + gap + chipSize.width, height),
    );
  }

  @override
  void performLayout() {
    size = _layout(
      constraints: constraints,
      measure: (child, childConstraints) {
        child.layout(childConstraints, parentUsesSize: true);
        return child.size;
      },
      place: (child, offset) {
        (child.parentData! as _ChildOffset).offset = offset;
      },
    );
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return _layout(
      constraints: constraints,
      measure: (child, childConstraints) =>
          child.getDryLayout(childConstraints),
    );
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return getDryLayout(const BoxConstraints()).width;
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
