import 'package:flutter/material.dart';
import '../tokens/color_tokens.dart';
import '../tokens/typography_tokens.dart';
import 'gap.dart';

/// Variants for [AppButton].
enum AppButtonVariant {
  primary,
  secondary,
  ghost,
  danger,
}

/// Sizes for [AppButton].
enum AppButtonSize {
  sm,
  md,
  lg,
}

/// Mobile-first button component for Clube de Leitura D'Elas.
///
/// Implements Primary, Secondary, Ghost, and Danger variants in Sm (32px),
/// Md (40px), and Lg (56px) sizes, with pill border radius (999px) and
/// native Material [InkWell] ripple splash on press (without hover state).
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
        width: 1.0,
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

    return Container(
      height: _height,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        border: border,
      ),
      child: Material(
        color: backgroundColor,
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: borderRadius,
          splashColor: splashColor,
          highlightColor: splashColor.withValues(alpha: 0.1),
          onTap: _isEnabled ? onPressed : null,
          child: Padding(
            padding: _padding,
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
  }

  Widget _buildChild(BuildContext context, Color foregroundColor) {
    if (isLoading) {
      return SizedBox(
        width: 16.0,
        height: 16.0,
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
        ),
      );
    }

    final labelWidget = Text(
      label,
      textAlign: TextAlign.center,
    );

    if (icon == null) {
      return labelWidget;
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
