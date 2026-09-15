import 'package:flutter/material.dart';

import '../tokens/color_tokens.dart';
import '../tokens/spacing_tokens.dart';
import '../tokens/typography_tokens.dart';
import 'gap.dart';

/// App-wide checkbox for Clube de Leitura D'Elas.
///
/// Controlled widget: the parent owns [value] and receives the next value
/// through [onChanged]. Pass `onChanged: null` to render the disabled state.
///
/// The painted box follows the Figma Checkbox (rounded square, brand fill
/// when checked). The hit target is larger than the drawing, and an optional
/// [label] is part of the same tap target — intended for the 60+ audience.
class AppCheckbox extends StatelessWidget {
  const AppCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
  });

  /// Whether the box is checked.
  final bool value;

  /// Called with the toggled value. `null` disables the control.
  final ValueChanged<bool>? onChanged;

  /// Optional text beside the box. Tapping it toggles [value].
  final String? label;

  /// Painted box side, from the spacing scale (24).
  static const double visualSize = 24;

  /// Minimum tap target side (48), larger than [visualSize].
  static const double hitSize = 48;

  bool get _isEnabled => onChanged != null;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final spacing = context.spacing;

    return Semantics(
      container: true,
      checked: value,
      enabled: _isEnabled,
      label: label,
      child: ExcludeSemantics(
        child: _CheckboxHitTarget(
          enabled: _isEnabled,
          splashColor: colors.surfaceBrandSoft,
          onTap: _isEnabled ? () => onChanged!(!value) : null,
          child: _CheckboxBody(
            value: value,
            enabled: _isEnabled,
            label: label,
            colors: colors,
            text: text,
            spacing: spacing,
          ),
        ),
      ),
    );
  }
}

class _CheckboxHitTarget extends StatelessWidget {
  const _CheckboxHitTarget({
    required this.enabled,
    required this.splashColor,
    required this.onTap,
    required this.child,
  });

  final bool enabled;
  final Color splashColor;
  final VoidCallback? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppCheckbox.hitSize / 2),
        splashColor: enabled ? splashColor : Colors.transparent,
        highlightColor: enabled
            ? splashColor.withValues(alpha: 0.35)
            : Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: AppCheckbox.hitSize,
            minHeight: AppCheckbox.hitSize,
          ),
          child: child,
        ),
      ),
    );
  }
}

class _CheckboxBody extends StatelessWidget {
  const _CheckboxBody({
    required this.value,
    required this.enabled,
    required this.label,
    required this.colors,
    required this.text,
    required this.spacing,
  });

  final bool value;
  final bool enabled;
  final String? label;
  final AppColorTokens colors;
  final AppTypographyTokens text;
  final AppSpacingTokens spacing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: spacing.s4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: AppCheckbox.hitSize,
            height: AppCheckbox.hitSize,
            child: Center(
              child: _CheckboxMark(
                value: value,
                enabled: enabled,
                colors: colors,
              ),
            ),
          ),
          if (label != null) ...[
            const Gap8(),
            Text(
              label!,
              style: text.bodyDefault.copyWith(
                color: enabled ? colors.textDefault : colors.actionDisabledFg,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CheckboxMark extends StatelessWidget {
  const _CheckboxMark({
    required this.value,
    required this.enabled,
    required this.colors,
  });

  final bool value;
  final bool enabled;
  final AppColorTokens colors;

  @override
  Widget build(BuildContext context) {
    final fill = _fillColor();
    final border = _borderColor();

    return SizedBox(
      width: AppCheckbox.visualSize,
      height: AppCheckbox.visualSize,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: border, width: 2),
        ),
        child: value
            ? Icon(
                Icons.check,
                size: 18,
                color: enabled ? colors.textOnBrand : colors.actionDisabledFg,
              )
            : null,
      ),
    );
  }

  Color _fillColor() {
    if (!enabled) {
      return value ? colors.actionDisabledBg : colors.surfaceDefault;
    }
    return value ? colors.actionPrimary : colors.surfaceDefault;
  }

  Color _borderColor() {
    if (!enabled) {
      return value ? colors.actionDisabledBg : colors.actionDisabledFg;
    }
    return value ? colors.actionPrimary : colors.borderStrong;
  }
}
