import 'package:flutter/material.dart';
import 'package:mobile/design_system/design_system.dart';

/// Linha de dado do encontro (ícone + texto). Diferente de `AppGroupInfoRow`,
/// o texto quebra em várias linhas em vez de ser cortado, para caber endereços
/// longos sem esconder informação.
///
/// Com [onTap], a linha vira um link: [linkLabel] (ou o texto todo) fica
/// sublinhado e ganha um destaque arredondado enquanto está pressionado.
class MeetingInfoRow extends StatefulWidget {
  const MeetingInfoRow({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.linkHint,
    this.linkLabel,
  });

  final AppIconAsset icon;
  final String label;
  final VoidCallback? onTap;

  /// O que o link faz, lido por leitores de tela (ex.: "Abrir no Google Maps").
  final String? linkHint;

  /// Trecho de [label] que aparece como link (sublinhado). Sem ele, a linha
  /// inteira fica sublinhada.
  final String? linkLabel;

  @override
  State<MeetingInfoRow> createState() => _MeetingInfoRowState();
}

class _MeetingInfoRowState extends State<MeetingInfoRow> {
  static const double _iconSize = 20;

  bool _pressed = false;

  void _setPressed(bool pressed) {
    if (_pressed != pressed) setState(() => _pressed = pressed);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppIcon(icon: widget.icon, size: _iconSize, color: colors.textMuted),
        SizedBox(width: spacing.s8),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: spacing.s2),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final style = DefaultTextStyle.of(context).style.merge(
                  context.typography.bodySmall.copyWith(
                    color: colors.textMuted,
                  ),
                );
                final span = _labelSpan(colors.textMuted);

                return CustomPaint(
                  painter: _pressed
                      ? _LinkHighlightPainter(
                          text: TextSpan(style: style, children: [span]),
                          range: _linkRange(),
                          textScaler: MediaQuery.textScalerOf(context),
                          textDirection: Directionality.of(context),
                          maxWidth: constraints.maxWidth,
                          color: colors.textMuted.withValues(alpha: 0.2),
                        )
                      : null,
                  child: Text.rich(span, style: style),
                );
              },
            ),
          ),
        ),
      ],
    );

    final onTap = widget.onTap;
    if (onTap == null) return row;

    return Semantics(
      link: true,
      hint: widget.linkHint,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          key: const ValueKey('meeting-info-link'),
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => _setPressed(true),
          onTapUp: (_) => _setPressed(false),
          onTapCancel: () => _setPressed(false),
          onTap: onTap,
          child: row,
        ),
      ),
    );
  }

  /// Posição do trecho do link dentro de [MeetingInfoRow.label].
  TextRange _linkRange() {
    final label = widget.label;
    final link = widget.linkLabel;
    final start = link == null ? -1 : label.indexOf(link);
    if (link == null || start < 0) {
      return TextRange(start: 0, end: label.length);
    }
    return TextRange(start: start, end: start + link.length);
  }

  InlineSpan _labelSpan(Color color) {
    final label = widget.label;
    if (widget.onTap == null) return TextSpan(text: label);

    final underline = TextStyle(
      decoration: TextDecoration.underline,
      decorationColor: color,
    );
    final range = _linkRange();

    return TextSpan(
      children: [
        TextSpan(text: label.substring(0, range.start)),
        TextSpan(text: range.textInside(label), style: underline),
        TextSpan(text: label.substring(range.end)),
      ],
    );
  }
}

/// Desenha um fundo arredondado atrás de cada linha ocupada pelo link.
class _LinkHighlightPainter extends CustomPainter {
  _LinkHighlightPainter({
    required this.text,
    required this.range,
    required this.textScaler,
    required this.textDirection,
    required this.maxWidth,
    required this.color,
  });

  final TextSpan text;
  final TextRange range;
  final TextScaler textScaler;
  final TextDirection textDirection;
  final double maxWidth;
  final Color color;

  static const _radius = Radius.circular(4);
  static const _padding = 2.0;

  @override
  void paint(Canvas canvas, Size size) {
    final painter = TextPainter(
      text: text,
      textDirection: textDirection,
      textScaler: textScaler,
    )..layout(maxWidth: maxWidth);

    final paint = Paint()..color = color;
    final boxes = painter.getBoxesForSelection(
      TextSelection(baseOffset: range.start, extentOffset: range.end),
    );
    for (final box in boxes) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(box.toRect().inflate(_padding), _radius),
        paint,
      );
    }
    painter.dispose();
  }

  @override
  bool shouldRepaint(_LinkHighlightPainter oldDelegate) =>
      oldDelegate.text != text ||
      oldDelegate.range != range ||
      oldDelegate.color != color ||
      oldDelegate.maxWidth != maxWidth ||
      oldDelegate.textScaler != textScaler;
}
