import 'package:flutter/material.dart';

import '../tokens/color_tokens.dart';
import '../tokens/spacing_tokens.dart';
import '../tokens/typography_tokens.dart';
import 'gap.dart';

enum AppChipVariant { filled, outlined }

/// Chip clicável do design system: mesma pílula do [AppTag], com toque e
/// estado de carregamento.
///
/// Sem [onTap] ou com [isLoading] o chip não responde ao toque. A área de
/// toque tem [hitHeight] de altura, maior que o desenho da pílula.
class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    this.variant = AppChipVariant.filled,
    this.icon,
    this.onTap,
    this.isLoading = false,
  });

  final String label;
  final AppChipVariant variant;
  final Widget? icon;
  final VoidCallback? onTap;
  final bool isLoading;

  /// Altura mínima da área de toque (48), pensada para o público 60+.
  static const double hitHeight = 48;

  bool get _isEnabled => onTap != null && !isLoading;

  @override
  Widget build(BuildContext context) {
    final handleTap = _isEnabled ? onTap : null;

    return Semantics(
      button: true,
      enabled: _isEnabled,
      label: label,
      onTap: handleTap,
      child: ExcludeSemantics(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: handleTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: hitHeight),
            child: Align(
              widthFactor: 1,
              heightFactor: 1,
              child: _AppChipPill(
                label: label,
                variant: variant,
                icon: icon,
                isLoading: isLoading,
                onTap: handleTap,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AppChipPill extends StatelessWidget {
  const _AppChipPill({
    required this.label,
    required this.variant,
    required this.icon,
    required this.isLoading,
    required this.onTap,
  });

  final String label;
  final AppChipVariant variant;
  final Widget? icon;
  final bool isLoading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final isFilled = variant == AppChipVariant.filled;
    final foreground = isFilled ? colors.textBrand : colors.actionPrimary;
    final shape = StadiumBorder(
      side: isFilled ? BorderSide.none : BorderSide(color: colors.borderBrand),
    );

    return Material(
      color: isFilled ? colors.surfaceBrandSoft : Colors.transparent,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        customBorder: shape,
        splashColor: colors.surfaceBrandSoft,
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.s16,
            vertical: spacing.s4,
          ),
          child: _AppChipContent(
            label: label,
            icon: icon,
            isLoading: isLoading,
            foreground: foreground,
          ),
        ),
      ),
    );
  }
}

class _AppChipContent extends StatelessWidget {
  const _AppChipContent({
    required this.label,
    required this.icon,
    required this.isLoading,
    required this.foreground,
  });

  final String label;
  final Widget? icon;
  final bool isLoading;
  final Color foreground;

  static const double _iconSize = 16;

  @override
  Widget build(BuildContext context) {
    final leading = isLoading
        ? SizedBox(
            width: _iconSize,
            height: _iconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(foreground),
            ),
          )
        : icon;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (leading != null) ...[
          IconTheme(
            data: IconThemeData(color: foreground, size: _iconSize),
            child: leading,
          ),
          const Gap4(),
        ],
        Text(
          label,
          style: context.typography.labelTag.copyWith(color: foreground),
        ),
      ],
    );
  }
}
