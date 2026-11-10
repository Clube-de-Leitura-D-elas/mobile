import 'package:flutter/material.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';

/// Mensagem de estado da lista, com nova tentativa quando [onRetry] é informado.
class NotificationsMessageView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const NotificationsMessageView({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final onRetry = this.onRetry;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(spacing.s24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              liveRegion: true,
              child: Text(
                message,
                style: context.typography.bodyDefault.copyWith(
                  color: context.colors.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (onRetry != null) ...[
              SizedBox(height: spacing.s16),
              AppButton.secondary(
                label: context.l10n.notificationsRetry,
                size: AppButtonSize.lg,
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
