import 'package:flutter/material.dart';

import '../../core/extensions/build_context_l10n.dart';
import '../tokens/color_tokens.dart';
import '../tokens/spacing_tokens.dart';
import '../tokens/typography_tokens.dart';
import 'app_button.dart';

/// Estado de erro de uma tela ou seção: a mensagem e o botão
/// "Tentar novamente" (quando há [onRetry]).
///
/// [secondaryLabel] + [onSecondary] mostram uma segunda saída abaixo, por
/// exemplo "Sair" quando tentar de novo não resolve.
class AppErrorState extends StatelessWidget {
  const AppErrorState({
    super.key,
    required this.message,
    this.onRetry,
    this.secondaryLabel,
    this.onSecondary,
  });

  final String message;
  final VoidCallback? onRetry;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final onRetry = this.onRetry;
    final secondaryLabel = this.secondaryLabel;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(spacing.s24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              liveRegion: true,
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: context.text.bodyDefault.copyWith(
                  color: context.colors.textDefault,
                ),
              ),
            ),
            if (onRetry != null) ...[
              SizedBox(height: spacing.s24),
              AppButton.primary(
                label: context.l10n.errorRetryButton,
                size: AppButtonSize.lg,
                onPressed: onRetry,
              ),
            ],
            if (secondaryLabel != null && onSecondary != null) ...[
              SizedBox(height: spacing.s12),
              AppButton.secondary(
                label: secondaryLabel,
                size: AppButtonSize.lg,
                onPressed: onSecondary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
