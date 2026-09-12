import 'package:flutter/material.dart';
import '../tokens/color_tokens.dart';
import '../tokens/typography_tokens.dart';
import 'gap.dart';

/// Input field size enum matching Figma specs (Md: 40px, Lg: 56px).
enum AppTextFieldSize {
  md,
  lg,
}

/// Mobile-first input field component for Clube de Leitura D'Elas.
///
/// Strictly follows Figma specs:
/// - Label: Body/Default Emphasis (Nunito 600, 16px, line height 24px)
/// - Container: 8px border radius, 1px borderDefault border, 2px actionFocusRing focus border
/// - Text: Body/Default (Nunito 400, 16px, line height 24px)
/// - Height: Md 40px, Lg 56px
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.label,
    this.hintText,
    this.helperText,
    this.errorText,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.autofocus = false,
    this.size = AppTextFieldSize.md,
    this.validator,
  });

  final String? label;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final bool autofocus;
  final AppTextFieldSize size;
  final String? Function(String?)? validator;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  double get _height {
    switch (widget.size) {
      case AppTextFieldSize.md:
        return 40.0;
      case AppTextFieldSize.lg:
        return 56.0;
    }
  }

  EdgeInsets get _contentPadding {
    switch (widget.size) {
      case AppTextFieldSize.md:
        return const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0);
      case AppTextFieldSize.lg:
        return const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.text;

    final baseBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(color: colors.borderDefault, width: 1.0),
    );

    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(color: colors.actionFocusRing, width: 2.0),
    );

    final errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(color: colors.feedbackError, width: 2.0),
    );

    Widget? effectiveSuffixIcon = widget.suffixIcon;
    if (widget.obscureText && widget.suffixIcon == null) {
      effectiveSuffixIcon = IconButton(
        icon: Icon(
          _isObscured
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          color: colors.textMuted,
          size: 20.0,
        ),
        onPressed: () {
          setState(() {
            _isObscured = !_isObscured;
          });
        },
      );
    }

    return FormField<String>(
      enabled: widget.enabled,
      initialValue: widget.controller?.text,
      validator: widget.validator,
      builder: (field) {
        final effectiveError = widget.errorText ?? field.errorText;
        final hasError = effectiveError != null && effectiveError.isNotEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.label != null) ...[
              Text(
                widget.label!,
                style: typography.bodyDefaultEmphasis.copyWith(
                  color: colors.textDefault,
                ),
              ),
              const Gap4(),
            ],
            SizedBox(
              height: _height,
              child: TextField(
                controller: widget.controller,
                onChanged: (value) {
                  field.didChange(value);
                  widget.onChanged?.call(value);
                },
                onSubmitted: widget.onSubmitted,
                obscureText: _isObscured,
                keyboardType: widget.keyboardType,
                textInputAction: widget.textInputAction,
                enabled: widget.enabled,
                autofocus: widget.autofocus,
                style: typography.bodyDefault.copyWith(
                  color: widget.enabled
                      ? colors.textDefault
                      : colors.actionDisabledFg,
                ),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: typography.bodyDefault.copyWith(
                    color: colors.textMuted,
                  ),
                  filled: true,
                  fillColor:
                      widget.enabled ? colors.bgDefault : colors.surfaceSunken,
                  contentPadding: _contentPadding,
                  border: baseBorder,
                  enabledBorder: hasError ? errorBorder : baseBorder,
                  focusedBorder: hasError ? errorBorder : focusedBorder,
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide:
                        BorderSide(color: colors.actionDisabledBg, width: 1.0),
                  ),
                  isDense: true,
                  prefixIcon: widget.prefixIcon,
                  suffixIcon: effectiveSuffixIcon,
                ),
              ),
            ),
            if (hasError || widget.helperText != null) ...[
              const Gap4(),
              Text(
                effectiveError ?? widget.helperText!,
                style: typography.caption.copyWith(
                  color: hasError ? colors.feedbackError : colors.textMuted,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
