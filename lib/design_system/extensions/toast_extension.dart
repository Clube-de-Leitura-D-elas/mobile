import 'package:flutter/widgets.dart';

import '../widgets/app_toast.dart';

/// Deixa o disparo de toasts idiomático nas telas/cubits do app, no
/// mesmo padrão de `context.l10n` e `context.colors`.
///
/// Sugerido em code review da task CLU-136: em vez de
/// `AppToast.show(context, message: ..., type: ...)` espalhado pelas
/// páginas, usar `context.showToast(...)` (ou os atalhos por tipo
/// abaixo) — menos boilerplate em handlers de clique e em
/// `BlocListener`s, e segue o padrão já usado no resto do app para
/// tudo que depende de [BuildContext].
extension ToastExtension on BuildContext {
  void showToast(
    String message, {
    AppToastType type = AppToastType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    AppToast.show(
      this,
      message: message,
      type: type,
      duration: duration,
    );
  }

  // Atalhos sintáticos — cobrem os quatro AppToastType existentes.
  void showSuccessToast(String message) => showToast(message, type: AppToastType.success);

  void showErrorToast(String message) => showToast(message, type: AppToastType.error);

  void showWarningToast(String message) => showToast(message, type: AppToastType.warning);

  void showInfoToast(String message) => showToast(message, type: AppToastType.info);
}
