import 'package:flutter/material.dart';
import 'package:mobile/design_system/design_system.dart';

class AppDropdown<T> extends StatelessWidget {
  final String label;
  final String? helperText;
  final String hintText;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;

  const AppDropdown({
    super.key,
    required this.label,
    this.helperText,
    required this.hintText,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final spacing = context.spacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: text.bodyDefaultEmphasis.copyWith(color: colors.textDefault),
        ),

        SizedBox(height: spacing.s4),
        DropdownButtonFormField<T>(
          value: value,
          onChanged: onChanged,
          items: items,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: colors.textMuted,
          ),
          style: text.bodyDefault.copyWith(color: colors.textDefault),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: text.bodyDefault.copyWith(color: colors.textMuted),
            helperText: helperText,
            helperStyle: text.caption.copyWith(color: colors.textMuted),
            contentPadding: EdgeInsets.symmetric(
              horizontal: spacing.s16,
              vertical: spacing.s8,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: colors.borderDefault),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: colors.borderDefault),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: colors.actionPrimary, width: 2.0),
            ),

          ),
        ),
      ],
    );
  }
}
