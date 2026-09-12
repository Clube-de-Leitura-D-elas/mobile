import 'package:flutter/material.dart';

import '../tokens/color_tokens.dart';
import '../tokens/spacing_tokens.dart';
import '../tokens/typography_tokens.dart';

enum TagVariant { primary, neutral }

class AppTag extends StatelessWidget {
  final String label;
  final TagVariant variant;
  final Widget? icon;

  const AppTag({
    super.key,
    required this.label,
    this.variant = TagVariant.primary,
    this.icon,
  });

  Color _getBackgroundColor(AppColorTokens colors) {
    switch (variant) {
      case TagVariant.primary:
        return colors.surfaceBrandSoft;
      case TagVariant.neutral:
        return colors.surfaceSunken;
    }
  }

  Color _getTextColor(AppColorTokens colors) {
    switch (variant) {
      case TagVariant.primary:
        return colors.textBrand;
      case TagVariant.neutral:
        return colors.textDefault;
    }
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final colors = context.colors;
    final textStyle = context.typography.labelTag.copyWith(
      color: _getTextColor(colors),
    );
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.s16,
        vertical: spacing.s4,
      ),
      decoration: BoxDecoration(
        color: _getBackgroundColor(colors),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            IconTheme(
              data: IconThemeData(color: _getTextColor(colors), size: 16),
              child: icon!,
            ),
            const SizedBox(width: 4),
          ],
          Text(label, style: textStyle),
        ],
      ),
    );
  }
}

// Exemplo de uso:
//
// Row(
//   children: const [
//     AppTag(label: 'Gestora', variant: TagVariant.primary),
//     SizedBox(width: 8),
//     AppTag(label: 'Gestora', variant: TagVariant.neutral),
//   ],
// )
