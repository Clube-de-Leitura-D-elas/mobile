import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'app_chip.dart';

/// Estados visuais do chip de status de leitura.
///
/// [markAsRead] é a chamada para ação usada no detalhe do livro.
enum ReadingStatusChipState { read, wantToRead, markAsRead }

/// Chip de status de leitura: "Já lido" (preenchido), "Quero ler" e
/// "Marcar como lido" (contorno).
class AppReadingStatusChip extends StatelessWidget {
  const AppReadingStatusChip({
    super.key,
    required this.state,
    this.onTap,
    this.isLoading = false,
  });

  final ReadingStatusChipState state;
  final VoidCallback? onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations);
    final isRead = state == ReadingStatusChipState.read;

    return AppChip(
      label: switch (state) {
        ReadingStatusChipState.read => l10n?.readingStatusRead ?? 'Já lido',
        ReadingStatusChipState.wantToRead =>
          l10n?.readingStatusWantToRead ?? 'Quero ler',
        ReadingStatusChipState.markAsRead =>
          l10n?.readingStatusMarkAsRead ?? 'Marcar como lido',
      },
      variant: isRead ? AppChipVariant.filled : AppChipVariant.outlined,
      icon: Icon(isRead ? Icons.check_circle : Icons.check_circle_outline),
      onTap: onTap,
      isLoading: isLoading,
    );
  }
}
