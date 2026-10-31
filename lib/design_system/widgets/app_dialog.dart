import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../tokens/color_tokens.dart';
import '../tokens/spacing_tokens.dart';
import '../tokens/typography_tokens.dart';
import 'gap.dart';

/// Modal base do design system: título, botão de fechar, conteúdo e ações.
///
/// [actions] ficam lado a lado com a mesma largura; sem ações o rodapé não é
/// renderizado. [onClose] é chamado pelo "x"; por padrão fecha o dialog.
/// [child] já fica dentro de um scroll: não passe `ListView` sem
/// `shrinkWrap`.
class AppDialog extends StatelessWidget {
  const AppDialog({
    super.key,
    required this.title,
    required this.child,
    this.actions = const [],
    this.onClose,
  });

  final String title;
  final Widget child;
  final List<Widget> actions;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      backgroundColor: context.colors.bgDefault,
      child: Padding(
        padding: EdgeInsets.all(context.spacing.s24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _AppDialogHeader(
              title: title,
              onClose: onClose ?? () => Navigator.of(context).pop(),
            ),
            const Gap16(),
            Flexible(child: SingleChildScrollView(child: child)),
            if (actions.isNotEmpty) ...[
              const Gap24(),
              _AppDialogActions(actions: actions),
            ],
          ],
        ),
      ),
    );
  }
}

class _AppDialogHeader extends StatelessWidget {
  const _AppDialogHeader({required this.title, required this.onClose});

  final String title;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations);

    return Row(
      children: [
        Expanded(
          child: Semantics(
            header: true,
            // No iOS o VoiceOver já foca o título ao abrir; nomear a rota
            // faria o título ser anunciado duas vezes (igual ao AlertDialog).
            namesRoute: defaultTargetPlatform != TargetPlatform.iOS,
            child: Text(
              title,
              style: context.typography.headingH3.copyWith(
                color: colors.textDefault,
              ),
            ),
          ),
        ),
        const Gap16(),
        SizedBox(
          width: 48,
          height: 48,
          child: IconButton(
            padding: EdgeInsets.zero,
            tooltip: l10n?.close ?? 'Fechar',
            onPressed: onClose,
            icon: Icon(Icons.close, color: colors.textDefault, size: 20),
          ),
        ),
      ],
    );
  }
}

class _AppDialogActions extends StatelessWidget {
  const _AppDialogActions({required this.actions});

  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < actions.length; i++) ...[
          if (i > 0) const Gap16(),
          Expanded(child: actions[i]),
        ],
      ],
    );
  }
}
