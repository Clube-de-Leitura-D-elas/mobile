import 'package:flutter/material.dart';

import '../tokens/color_tokens.dart';
import '../tokens/spacing_tokens.dart';
import '../tokens/typography_tokens.dart';

enum CardVariant { normal, highlighted }

class AppCard extends StatefulWidget {
  final Widget child;
  final CardVariant variant;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.variant = CardVariant.normal,
    this.onTap,
  });

  factory AppCard.titled({
    Key? key,
    required String title,
    required String supportText,
    CardVariant variant = CardVariant.normal,
    VoidCallback? onTap,
  }) {
    return AppCard(
      key: key,
      variant: variant,
      onTap: onTap,
      child: Builder(
        builder: (context) {
          final colors = context.colors;
          final typography = context.typography;
          final spacing = context.spacing;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: typography.bodyDefaultEmphasis.copyWith(
                  color: colors.textDefault,
                ),
              ),
              SizedBox(height: spacing.s4),
              Text(
                supportText,
                style: typography.bodySmall.copyWith(color: colors.textMuted),
              ),
            ],
          );
        },
      ),
    );
  }

  static const double borderRadius = 16;

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _isToggled = false;

  CardVariant get _effectiveVariant => _isToggled
      ? (widget.variant == CardVariant.normal
            ? CardVariant.highlighted
            : CardVariant.normal)
      : widget.variant;

  Color _getBorderColor(AppColorTokens colors) {
    switch (_effectiveVariant) {
      case CardVariant.normal:
        return colors.borderDefault;
      case CardVariant.highlighted:
        return colors.borderBrand;
    }
  }

  double _getBorderWidth() {
    switch (_effectiveVariant) {
      case CardVariant.normal:
        return 1;
      case CardVariant.highlighted:
        return 1.5;
    }
  }

  void _handleTap() {
    setState(() => _isToggled = !_isToggled);
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    final decoration = BoxDecoration(
      color: colors.surfaceDefault,
      borderRadius: BorderRadius.circular(AppCard.borderRadius),
      border: Border.all(
        color: _getBorderColor(colors),
        width: _getBorderWidth(),
      ),
    );

    if (widget.onTap == null) {
      return Container(
        padding: EdgeInsets.all(spacing.s16),
        decoration: decoration,
        child: widget.child,
      );
    }

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppCard.borderRadius),
      child: InkWell(
        onTap: _handleTap,
        borderRadius: BorderRadius.circular(AppCard.borderRadius),
        child: Ink(
          padding: EdgeInsets.all(spacing.s16),
          decoration: decoration,
          child: widget.child,
        ),
      ),
    );
  }
}

/* Exemplo de uso:

 AppCard.titled(
   title: 'Clube de Leitura Central',
   supportText: '12 participantes · próximo encontro dia 20',
   onTap: () => Navigator.pushNamed(context, '/grupo'),
 ),

 AppCard(
   variant: CardVariant.highlighted,
   child: MinhaTarefaCustomizada(),
 ), */
