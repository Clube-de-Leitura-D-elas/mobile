import 'package:flutter/material.dart';

import '../tokens/color_tokens.dart';
import '../tokens/spacing_tokens.dart';
import '../tokens/typography_tokens.dart';

enum AppDropdownSize {
  md,
  lg,
}

/// Reusable dropdown component from the Design System.
///
/// The selected value is controlled by the parent through [initialSelection].
/// The component delegates the dropdown behavior to Flutter's [DropdownMenu].
///
/// Business logic and selection state must remain outside this component.
class AppDropdown<T> extends StatelessWidget {
  const AppDropdown({
    super.key,
    required this.items,
    this.initialSelection,
    this.onSelected,
    this.label,
    this.hintText,
    this.enabled = true,
    this.size = AppDropdownSize.md,
    this.controller,
  });

  /// Available dropdown options.
  final List<DropdownMenuEntry<T>> items;

  /// Initial/current selection displayed by Flutter's DropdownMenu.
  final T? initialSelection;

  /// Called when the user selects an option.
  final ValueChanged<T?>? onSelected;

  /// Optional text displayed as the field label.
  final String? label;

  /// Optional hint displayed when there is no selection.
  final String? hintText;

  /// Whether the dropdown is enabled.
  final bool enabled;

  /// Dropdown size variant.
  final AppDropdownSize size;

  /// Optional controller for the underlying DropdownMenu.
  final TextEditingController? controller;

  double get _fieldHeight {
    switch (size) {
      case AppDropdownSize.md:
        return 40.0;
      case AppDropdownSize.lg:
        return 56.0;
    }
  }

  EdgeInsets get _contentPadding {
    switch (size) {
      case AppDropdownSize.md:
        return const EdgeInsets.symmetric(horizontal: 16.0);
      case AppDropdownSize.lg:
        return const EdgeInsets.symmetric(horizontal: 16.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.text;
    final spacing = context.spacing;

    return DropdownMenu<T>(
      controller: controller,
      initialSelection: initialSelection,
      enabled: enabled,
      dropdownMenuEntries: items,
      onSelected: onSelected,
      label: label != null ? Text(label!) : null,
      hintText: hintText,
      width: double.infinity,
      textStyle: typography.bodyDefault.copyWith(
        color: enabled
            ? colors.textDefault
            : colors.actionDisabledFg,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: enabled
            ? colors.bgDefault
            : colors.surfaceSunken,
        contentPadding: _contentPadding,
        constraints: BoxConstraints(
          minHeight: _fieldHeight,
          maxHeight: _fieldHeight,
        ),
        labelStyle: typography.bodyDefaultEmphasis.copyWith(
          color: enabled
              ? colors.textDefault
              : colors.actionDisabledFg,
        ),
        hintStyle: typography.bodyDefault.copyWith(
          color: colors.textMuted,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: colors.borderDefault,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: colors.actionFocusRing,
            width: 2.0,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: colors.actionDisabledBg,
          ),
        ),
      ),
      menuStyle: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(
          colors.surfaceDefault,
        ),
        elevation: const WidgetStatePropertyAll(8.0),
        maximumSize: const WidgetStatePropertyAll(
          Size(double.infinity, 280.0),
        ),
      ),
    );
  }
}