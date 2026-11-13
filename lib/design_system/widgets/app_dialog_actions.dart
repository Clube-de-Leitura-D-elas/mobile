import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';

import '../tokens/spacing_tokens.dart';

/// Rodapé de ações de um dialog.
///
/// As ações ficam lado a lado, com a mesma largura e a mesma altura, enquanto
/// todos os labels cabem numa linha. Se algum quebraria, elas são empilhadas
/// na largura toda, com a última da lista em cima: passe a ação principal por
/// último.
///
/// As ações precisam responder a dry layout (o [AppButton] responde), e o pai
/// precisa limitar a largura.
class AppDialogActions extends StatelessWidget {
  const AppDialogActions({super.key, required this.actions});

  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return _AdaptiveActions(
      spacing: spacing.s16,
      runSpacing: spacing.s8,
      children: actions,
    );
  }
}

class _AdaptiveActions extends MultiChildRenderObjectWidget {
  const _AdaptiveActions({
    required this.spacing,
    required this.runSpacing,
    super.children,
  });

  final double spacing;
  final double runSpacing;

  @override
  _RenderAdaptiveActions createRenderObject(BuildContext context) {
    return _RenderAdaptiveActions(spacing: spacing, runSpacing: runSpacing);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderAdaptiveActions renderObject,
  ) {
    renderObject
      ..spacing = spacing
      ..runSpacing = runSpacing;
  }
}

class _ActionsParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderAdaptiveActions extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _ActionsParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _ActionsParentData> {
  _RenderAdaptiveActions({required double spacing, required double runSpacing})
    : _spacing = spacing,
      _runSpacing = runSpacing;

  double _spacing;
  double get spacing => _spacing;
  set spacing(double value) {
    if (_spacing == value) {
      return;
    }
    _spacing = value;
    markNeedsLayout();
  }

  double _runSpacing;
  double get runSpacing => _runSpacing;
  set runSpacing(double value) {
    if (_runSpacing == value) {
      return;
    }
    _runSpacing = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _ActionsParentData) {
      child.parentData = _ActionsParentData();
    }
  }

  List<RenderBox> get _children {
    final result = <RenderBox>[];
    var child = firstChild;
    while (child != null) {
      result.add(child);
      child = childAfter(child);
    }
    return result;
  }

  double _slotWidth(double width, int count) {
    return math.max(0, (width - _spacing * (count - 1)) / count);
  }

  // Uma ação "quebra" quando fica mais alta na fatia do que com largura livre.
  // A dry layout reproduz o padding que o AppButton usa com largura imposta,
  // coisa que as larguras intrínsecas não fazem.
  bool _fitsSideBySide(List<RenderBox> children, double width) {
    final slot = BoxConstraints.tightFor(
      width: _slotWidth(width, children.length),
    );
    return children.every(
      (child) =>
          child.getDryLayout(slot).height <=
          child.getDryLayout(const BoxConstraints()).height,
    );
  }

  /// Calcula o tamanho e, quando [place] é dado, faz o layout dos filhos.
  Size _layout(
    BoxConstraints constraints, {
    required ChildLayouter layoutChild,
    void Function(RenderBox child, Offset offset, BoxConstraints constraints)?
    place,
  }) {
    final children = _children;
    if (children.isEmpty) {
      return constraints.smallest;
    }
    assert(
      constraints.hasBoundedWidth,
      'AppDialogActions precisa de largura limitada.',
    );
    final width = constraints.maxWidth;

    if (_fitsSideBySide(children, width)) {
      final slot = _slotWidth(width, children.length);
      var height = 0.0;
      for (final child in children) {
        height = math.max(
          height,
          layoutChild(child, BoxConstraints.tightFor(width: slot)).height,
        );
      }
      final childConstraints = BoxConstraints.tightFor(
        width: slot,
        height: height,
      );
      var x = 0.0;
      for (final child in children) {
        layoutChild(child, childConstraints);
        place?.call(child, Offset(x, 0), childConstraints);
        x += slot + _spacing;
      }
      return constraints.constrain(Size(width, height));
    }

    final childConstraints = BoxConstraints.tightFor(width: width);
    var y = 0.0;
    for (final child in children.reversed) {
      final childSize = layoutChild(child, childConstraints);
      place?.call(child, Offset(0, y), childConstraints);
      y += childSize.height + _runSpacing;
    }
    return constraints.constrain(Size(width, y - _runSpacing));
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return _layout(constraints, layoutChild: ChildLayoutHelper.dryLayoutChild);
  }

  @override
  void performLayout() {
    size = _layout(
      constraints,
      layoutChild: ChildLayoutHelper.layoutChild,
      place: (child, offset, _) =>
          (child.parentData! as _ActionsParentData).offset = offset,
    );
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    return _children.fold(
      0.0,
      (width, child) => math.max(width, child.getMinIntrinsicWidth(height)),
    );
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    final children = _children;
    if (children.isEmpty) {
      return 0;
    }
    return children.fold(
          0.0,
          (width, child) => width + child.getMaxIntrinsicWidth(height),
        ) +
        _spacing * (children.length - 1);
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    if (!width.isFinite) {
      return _children.fold(
        0.0,
        (height, child) => math.max(height, child.getMinIntrinsicHeight(width)),
      );
    }
    return getDryLayout(BoxConstraints(maxWidth: width)).height;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return computeMinIntrinsicHeight(width);
  }

  @override
  double? computeDryBaseline(
    BoxConstraints constraints,
    TextBaseline baseline,
  ) {
    double? result;
    _layout(
      constraints,
      layoutChild: ChildLayoutHelper.dryLayoutChild,
      place: (child, offset, childConstraints) {
        final childBaseline = child.getDryBaseline(childConstraints, baseline);
        if (childBaseline != null) {
          final value = childBaseline + offset.dy;
          result = result == null ? value : math.min(result!, value);
        }
      },
    );
    return result;
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    return defaultComputeDistanceToHighestActualBaseline(baseline);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }
}
