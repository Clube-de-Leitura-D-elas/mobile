import 'dart:async';

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../icons/app_icons.dart';
import '../tokens/color_tokens.dart';
import '../tokens/spacing_tokens.dart';
import '../tokens/typography_tokens.dart';
import 'app_icon.dart';

/// Campo de busca em pílula do design system.
///
/// O [onChanged] só dispara depois de [debounce] sem digitação, para a lista
/// filtrar quando a usuária pausa e não a cada tecla. Enviar pelo teclado ou
/// tocar no botão de limpar (visível enquanto há texto) dispara na hora.
class AppSearchField extends StatefulWidget {
  const AppSearchField({
    super.key,
    required this.hintText,
    this.controller,
    this.onChanged,
    this.debounce = defaultDebounce,
  });

  final String hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final Duration debounce;

  static const Duration defaultDebounce = Duration(milliseconds: 300);

  /// Altura do campo (48), que também é a área de toque do botão de limpar.
  static const double height = 48;

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  TextEditingController? _ownedController;
  Timer? _debounceTimer;

  TextEditingController get _controller =>
      widget.controller ?? _ownedController!;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _ownedController = TextEditingController();
    }
  }

  @override
  void didUpdateWidget(AppSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller == oldWidget.controller) {
      return;
    }
    if (widget.controller == null) {
      _ownedController = TextEditingController(
        text: oldWidget.controller?.text,
      );
    } else {
      _ownedController?.dispose();
      _ownedController = null;
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _ownedController?.dispose();
    super.dispose();
  }

  void _handleChanged(String _) {
    _debounceTimer?.cancel();
    // Lê o texto no disparo: o controller pode ter sido trocado na espera.
    _debounceTimer = Timer(
      widget.debounce,
      () => widget.onChanged?.call(_controller.text),
    );
  }

  void _notifyNow(String value) {
    _debounceTimer?.cancel();
    widget.onChanged?.call(value);
  }

  void _clear() {
    _controller.clear();
    _notifyNow('');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;
    final l10n = AppLocalizations.of(context);
    // 14 e 10 do Figma, compostos a partir da escala de espaçamento.
    final edgeInset = spacing.s12 + spacing.s2;
    final iconGap = spacing.s8 + spacing.s2;

    return Container(
      height: AppSearchField.height,
      decoration: BoxDecoration(
        color: colors.bgDefault,
        borderRadius: BorderRadius.circular(98),
        // Borda por fora para não comer os 48 px do alvo de toque do limpar.
        border: Border.all(
          color: colors.borderDefault,
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
      ),
      padding: EdgeInsetsDirectional.only(start: edgeInset),
      child: Row(
        children: [
          ExcludeSemantics(
            child: AppIcon(
              icon: AppIcons.search,
              size: 18,
              color: colors.textMuted,
            ),
          ),
          SizedBox(width: iconGap),
          Expanded(
            // O hint some ao digitar; o rótulo mantém o campo identificado
            // para o leitor de tela.
            child: Semantics(
              label: widget.hintText,
              child: TextField(
                controller: _controller,
                onChanged: _handleChanged,
                onSubmitted: _notifyNow,
                textInputAction: TextInputAction.search,
                style: typography.bodyDefault.copyWith(
                  color: colors.textDefault,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  // Fora da semântica: o rótulo acima já anuncia o hint.
                  hint: ExcludeSemantics(
                    child: Text(
                      widget.hintText,
                      style: typography.bodyDefault.copyWith(
                        color: colors.actionDisabledFg,
                      ),
                    ),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (context, value, _) {
              // Mantém o respiro da borda direita quando o botão some.
              if (value.text.isEmpty) {
                return SizedBox(width: edgeInset);
              }

              return SizedBox.square(
                dimension: AppSearchField.height,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  tooltip: l10n.clearSearchTooltip,
                  onPressed: _clear,
                  icon: Icon(Icons.close, size: 20, color: colors.textMuted),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
