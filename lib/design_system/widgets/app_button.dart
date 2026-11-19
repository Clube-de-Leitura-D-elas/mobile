import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';

import '../tokens/color_tokens.dart';
import '../tokens/spacing_tokens.dart';
import '../tokens/typography_tokens.dart';
import 'gap.dart';

/// Variants for [AppButton].
enum AppButtonVariant { primary, secondary, ghost, danger }

/// Sizes for [AppButton].
enum AppButtonSize { sm, md, lg }

/// Mobile-first button component for Clube de Leitura D'Elas.
///
/// Implements Primary, Secondary, Ghost, and Danger variants in Sm (32px),
/// Md (40px), and Lg (56px) sizes, with pill border radius (999px) and
/// native Material [InkWell] ripple splash on press (without hover state).
/// Sm keeps a 48x48 touch target around the 32px visible button.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.md,
    this.icon,
    this.iconAlignment = IconAlignment.start,
    this.isLoading = false,
  });

  /// Primary action button.
  const AppButton.primary({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = AppButtonSize.md,
    this.icon,
    this.iconAlignment = IconAlignment.start,
    this.isLoading = false,
  }) : variant = AppButtonVariant.primary;

  /// Secondary action button.
  const AppButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = AppButtonSize.md,
    this.icon,
    this.iconAlignment = IconAlignment.start,
    this.isLoading = false,
  }) : variant = AppButtonVariant.secondary;

  /// Ghost action button.
  const AppButton.ghost({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = AppButtonSize.md,
    this.icon,
    this.iconAlignment = IconAlignment.start,
    this.isLoading = false,
  }) : variant = AppButtonVariant.ghost;

  /// Danger action button.
  const AppButton.danger({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = AppButtonSize.md,
    this.icon,
    this.iconAlignment = IconAlignment.start,
    this.isLoading = false,
  }) : variant = AppButtonVariant.danger;

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final Widget? icon;
  final IconAlignment iconAlignment;
  final bool isLoading;

  bool get _isEnabled => onPressed != null && !isLoading;

  double get _height {
    switch (size) {
      case AppButtonSize.sm:
        return 32.0;
      case AppButtonSize.md:
        return 40.0;
      case AppButtonSize.lg:
        return 56.0;
    }
  }

  static const double _borderWidth = 1.0;

  EdgeInsets _tightWidthPadding(double horizontal) {
    if (_padding.left <= horizontal) {
      return _padding;
    }
    return _padding.copyWith(left: horizontal, right: horizontal);
  }

  EdgeInsets get _padding {
    switch (size) {
      case AppButtonSize.sm:
        return const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0);
      case AppButtonSize.md:
        return const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0);
      case AppButtonSize.lg:
        return const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0);
    }
  }

  TextStyle _getTextStyle(BuildContext context) {
    final textTokens = context.text;
    switch (size) {
      case AppButtonSize.sm:
        return textTokens.labelTag;
      case AppButtonSize.md:
      case AppButtonSize.lg:
        return textTokens.labelButton;
    }
  }

  Color _getBackgroundColor(AppColorTokens colors) {
    if (!_isEnabled) {
      if (variant == AppButtonVariant.ghost) return Colors.transparent;
      return colors.actionDisabledBg;
    }

    switch (variant) {
      case AppButtonVariant.primary:
        return colors.actionPrimary;
      case AppButtonVariant.secondary:
      case AppButtonVariant.ghost:
        return Colors.transparent;
      case AppButtonVariant.danger:
        return colors.actionDanger;
    }
  }

  Color _getForegroundColor(AppColorTokens colors) {
    if (!_isEnabled) {
      return colors.actionDisabledFg;
    }

    switch (variant) {
      case AppButtonVariant.primary:
      case AppButtonVariant.danger:
        return colors.textOnBrand;
      case AppButtonVariant.secondary:
        return colors.actionPrimary;
      case AppButtonVariant.ghost:
        return colors.textBrand;
    }
  }

  Color _getSplashColor(AppColorTokens colors) {
    switch (variant) {
      case AppButtonVariant.primary:
        return colors.actionPrimaryPressed.withValues(alpha: 0.3);
      case AppButtonVariant.secondary:
      case AppButtonVariant.ghost:
        return colors.surfaceBrandSoft;
      case AppButtonVariant.danger:
        return colors.feedbackErrorDark.withValues(alpha: 0.3);
    }
  }

  Border? _getBorder(AppColorTokens colors) {
    if (variant == AppButtonVariant.secondary) {
      return Border.all(
        color: _isEnabled ? colors.actionPrimary : colors.actionDisabledBg,
        width: _borderWidth,
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyle = _getTextStyle(context);
    final backgroundColor = _getBackgroundColor(colors);
    final foregroundColor = _getForegroundColor(colors);
    final splashColor = _getSplashColor(colors);
    final border = _getBorder(colors);
    final borderRadius = BorderRadius.circular(999.0);

    // Altura mínima, não fixa: com fonte grande ou label longo o botão cresce
    // em vez de cortar a segunda linha do texto.
    final Widget button = Container(
      constraints: BoxConstraints(minHeight: _height),
      decoration: BoxDecoration(borderRadius: borderRadius, border: border),
      child: Material(
        color: backgroundColor,
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: borderRadius,
          splashColor: splashColor,
          highlightColor: splashColor.withValues(alpha: 0.1),
          onTap: _isEnabled ? onPressed : null,
          child: _ButtonPadding(
            padding: _withoutBorder(_padding, border),
            tightWidthPadding: _withoutBorder(
              _tightWidthPadding(context.spacing.s16),
              border,
            ),
            child: DefaultTextStyle(
              style: textStyle.copyWith(color: foregroundColor),
              child: IconTheme(
                data: IconThemeData(
                  color: foregroundColor,
                  size: textStyle.fontSize,
                ),
                child: _buildChild(context, foregroundColor),
              ),
            ),
          ),
        ),
      ),
    );

    // O Semantics fica por fora do alvo de toque para o nó acessível ter a
    // mesma área que responde ao toque.
    return Semantics(
      button: true,
      enabled: _isEnabled,
      label: label,
      child: size == AppButtonSize.sm
          ? _TapTargetPadding(child: button)
          : button,
    );
  }

  // A borda do Container já consome espaço; descontá-la do padding mantém a
  // área do label igual à dos botões sem borda (sem cortar o texto no md).
  EdgeInsets _withoutBorder(EdgeInsets padding, Border? border) {
    return border == null
        ? padding
        : padding - const EdgeInsets.all(_borderWidth);
  }

  Widget _buildChild(BuildContext context, Color foregroundColor) {
    if (isLoading) {
      return Center(
        heightFactor: 1,
        child: SizedBox(
          width: 16.0,
          height: 16.0,
          child: CircularProgressIndicator(
            strokeWidth: 2.0,
            valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
          ),
        ),
      );
    }

    final labelWidget = Text(label, textAlign: TextAlign.center);

    // Sem Center, o Text ocupa toda a altura mínima do botão e é desenhado no
    // topo, deixando o label acima do centro (visível nos botões sm).
    if (icon == null) {
      return Center(heightFactor: 1, child: labelWidget);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: iconAlignment == IconAlignment.start
          ? [icon!, const Gap8(), labelWidget]
          : [labelWidget, const Gap8(), icon!],
    );
  }
}

/// Usa [tightWidthPadding] quando o pai impõe a largura. Não troque por
/// `LayoutBuilder`: ele não responde às dimensões intrínsecas.
class _ButtonPadding extends SingleChildRenderObjectWidget {
  const _ButtonPadding({
    required this.padding,
    required this.tightWidthPadding,
    super.child,
  });

  final EdgeInsets padding;
  final EdgeInsets tightWidthPadding;

  @override
  _RenderButtonPadding createRenderObject(BuildContext context) {
    return _RenderButtonPadding(
      padding: padding,
      tightWidthPadding: tightWidthPadding,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderButtonPadding renderObject,
  ) {
    renderObject
      ..padding = padding
      ..tightWidthPadding = tightWidthPadding;
  }
}

class _RenderButtonPadding extends RenderShiftedBox {
  _RenderButtonPadding({
    required EdgeInsets padding,
    required EdgeInsets tightWidthPadding,
  }) : _padding = padding,
       _tightWidthPadding = tightWidthPadding,
       super(null);

  EdgeInsets _padding;
  EdgeInsets get padding => _padding;
  set padding(EdgeInsets value) {
    if (_padding == value) {
      return;
    }
    _padding = value;
    markNeedsLayout();
  }

  EdgeInsets _tightWidthPadding;
  EdgeInsets get tightWidthPadding => _tightWidthPadding;
  set tightWidthPadding(EdgeInsets value) {
    if (_tightWidthPadding == value) {
      return;
    }
    _tightWidthPadding = value;
    markNeedsLayout();
  }

  EdgeInsets _paddingFor(BoxConstraints constraints) {
    return constraints.hasTightWidth ? _tightWidthPadding : _padding;
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    final childWidth =
        child?.getMinIntrinsicWidth(math.max(0, height - _padding.vertical));
    return _padding.horizontal + (childWidth ?? 0);
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    final childWidth =
        child?.getMaxIntrinsicWidth(math.max(0, height - _padding.vertical));
    return _padding.horizontal + (childWidth ?? 0);
  }

  // A altura usa o padding largo: o label fica mais estreito e nunca ocupa
  // menos linhas do que no layout real, que pode vir com largura frouxa.
  @override
  double computeMinIntrinsicHeight(double width) {
    final p = _padding;
    final childHeight =
        child?.getMinIntrinsicHeight(math.max(0, width - p.horizontal));
    return p.vertical + (childHeight ?? 0);
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    final p = _padding;
    final childHeight =
        child?.getMaxIntrinsicHeight(math.max(0, width - p.horizontal));
    return p.vertical + (childHeight ?? 0);
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final p = _paddingFor(constraints);
    final childSize =
        child?.getDryLayout(constraints.deflate(p)) ?? Size.zero;
    return constraints.constrain(
      Size(p.horizontal + childSize.width, p.vertical + childSize.height),
    );
  }

  @override
  double? computeDryBaseline(
    BoxConstraints constraints,
    TextBaseline baseline,
  ) {
    final p = _paddingFor(constraints);
    final childBaseline = child?.getDryBaseline(
      constraints.deflate(p),
      baseline,
    );
    return childBaseline == null ? null : childBaseline + p.top;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<EdgeInsets>('padding', _padding))
      ..add(
        DiagnosticsProperty<EdgeInsets>('tightWidthPadding', _tightWidthPadding),
      );
  }

  @override
  void performLayout() {
    final p = _paddingFor(constraints);
    final child = this.child;
    if (child == null) {
      size = constraints.constrain(Size(p.horizontal, p.vertical));
      return;
    }
    child.layout(constraints.deflate(p), parentUsesSize: true);
    (child.parentData! as BoxParentData).offset = Offset(p.left, p.top);
    size = constraints.constrain(
      Size(p.horizontal + child.size.width, p.vertical + child.size.height),
    );
  }
}

/// Alvo de toque mínimo de 48x48 em volta do botão visível, como o
/// `MaterialTapTargetSize.padded` do Material: o toque na sobra é repassado ao
/// centro do botão.
class _TapTargetPadding extends SingleChildRenderObjectWidget {
  const _TapTargetPadding({required Widget super.child});

  @override
  _RenderTapTargetPadding createRenderObject(BuildContext context) {
    return _RenderTapTargetPadding();
  }
}

class _RenderTapTargetPadding extends RenderShiftedBox {
  _RenderTapTargetPadding() : super(null);

  static const double _minSize = 48.0;

  RenderBox get _child => child!;

  @override
  double computeMinIntrinsicWidth(double height) {
    return math.max(_child.getMinIntrinsicWidth(height), _minSize);
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return math.max(_child.getMaxIntrinsicWidth(height), _minSize);
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return math.max(_child.getMinIntrinsicHeight(width), _minSize);
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return math.max(_child.getMaxIntrinsicHeight(width), _minSize);
  }

  // Altura imposta de até 48 (ex.: IntrinsicHeight, que mede 48 aqui) é
  // absorvida pelo padding; acima disso o botão visível estica.
  BoxConstraints _childConstraints(BoxConstraints constraints) {
    return constraints.minHeight <= _minSize
        ? constraints.copyWith(minHeight: 0)
        : constraints;
  }

  Size _sizeFor(BoxConstraints constraints, Size childSize) {
    return constraints.constrain(
      Size(
        math.max(childSize.width, _minSize),
        math.max(childSize.height, _minSize),
      ),
    );
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return _sizeFor(
      constraints,
      _child.getDryLayout(_childConstraints(constraints)),
    );
  }

  @override
  double? computeDryBaseline(
    BoxConstraints constraints,
    TextBaseline baseline,
  ) {
    final childConstraints = _childConstraints(constraints);
    final childBaseline = _child.getDryBaseline(childConstraints, baseline);
    if (childBaseline == null) {
      return null;
    }
    final childSize = _child.getDryLayout(childConstraints);
    final offset = Alignment.center.alongOffset(
      _sizeFor(constraints, childSize) - childSize as Offset,
    );
    return childBaseline + offset.dy;
  }

  @override
  void performLayout() {
    _child.layout(_childConstraints(constraints), parentUsesSize: true);
    size = _sizeFor(constraints, _child.size);
    (_child.parentData! as BoxParentData).offset = Alignment.center.alongOffset(
      size - _child.size as Offset,
    );
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (super.hitTest(result, position: position)) {
      return true;
    }
    // Hoje o Semantics em volta já barra toques fora; sem esta checagem, se ele
    // sair daqui, Row e Stack desviariam para o botão toques fora dele.
    if (!size.contains(position)) {
      return false;
    }
    final center = _child.size.center(Offset.zero);
    return result.addWithRawTransform(
      transform: MatrixUtils.forceToPoint(center),
      position: center,
      hitTest: (result, position) => _child.hitTest(result, position: center),
    );
  }
}
