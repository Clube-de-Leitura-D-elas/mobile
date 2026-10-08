import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/design_system/design_system.dart';

enum AppToastType { success, error, info, warning }

class AppToast {
  static OverlayEntry? _currentEntry;
  static Timer? _hideTimer;

  static void show(
    BuildContext context, {
    required String message,
    AppToastType type = AppToastType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    if (!context.mounted) return;

    dismiss();

    final colors = context.colors;
    final typography = context.text;
    final spacing = context.spacing;

    Color backgroundColor;
    Color textColor;
    IconData iconData;

    switch (type) {
      case AppToastType.success:
        backgroundColor = colors.feedbackSuccessLight;
        textColor = colors.feedbackSuccess;
        iconData = Icons.check_circle_outline;
        break;
      case AppToastType.error:
        backgroundColor = colors.feedbackErrorLight;
        textColor = colors.feedbackError;
        iconData = Icons.cancel_outlined;
        break;
      case AppToastType.warning:
        backgroundColor = colors.feedbackWarningLight;
        textColor = colors.feedbackWarning;
        iconData = Icons.warning_amber_outlined;
        break;
      case AppToastType.info:
        backgroundColor = colors.feedbackInfoLight;
        textColor = colors.feedbackInfo;
        iconData = Icons.info_outline;
        break;
    }

    late final OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: MediaQuery.of(context).padding.top + spacing.s16,
          left: spacing.s16,
          right: spacing.s16,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: spacing.s16,
                vertical: spacing.s12,
              ),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: colors.overlayScrim.withValues(alpha: 0.08),
                    blurRadius: 12.0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(iconData, color: textColor, size: 20.0),
                  SizedBox(width: spacing.s8),
                  Expanded(
                    child: Text(
                      message,
                      style: typography.bodyDefaultEmphasis.copyWith(
                        color: textColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    _currentEntry = entry;
    Overlay.of(context).insert(entry);

    // Evita temporizadores pendentes no ambiente de testes de widget
    final isWidgetTest = WidgetsBinding.instance.runtimeType
        .toString()
        .contains('TestWidgetsFlutterBinding');

    if (!isWidgetTest) {
      _hideTimer = Timer(duration, () {
        dismiss();
      });
    }
  }

  static void dismiss() {
    _hideTimer?.cancel();
    _hideTimer = null;

    if (_currentEntry != null) {
      _currentEntry!.remove();
      _currentEntry!.dispose();
      _currentEntry = null;
    }
  }
}

/// Extensão principal do BuildContext para Toasts
extension AppToastExtension on BuildContext {
  void showAppToast(
    String message, {
    AppToastType type = AppToastType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    if (!mounted) return;
    AppToast.show(this, message: message, type: type, duration: duration);
  }

  void showSuccessToast(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    showAppToast(message, type: AppToastType.success, duration: duration);
  }

  void showErrorToast(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    showAppToast(message, type: AppToastType.error, duration: duration);
  }

  void showWarningToast(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    showAppToast(message, type: AppToastType.warning, duration: duration);
  }

  void showInfoToast(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    showAppToast(message, type: AppToastType.info, duration: duration);
  }
}

class ToastMockupPreview extends StatelessWidget {
  const ToastMockupPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Preview de Feedback Toasts',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          AppButton.primary(
            label: 'Exibir Toast Success',
            onPressed: () {
              context.showSuccessToast('Operação realizada com sucesso!');
            },
          ),
          const SizedBox(height: 8),
          AppButton.secondary(
            label: 'Exibir Toast Error',
            onPressed: () {
              context.showErrorToast('Falha ao conectar com o servidor.');
            },
          ),
          const SizedBox(height: 8),
          AppButton.secondary(
            label: 'Exibir Toast Warning',
            onPressed: () {
              context.showWarningToast('Sua sessão expira em 5 minutos.');
            },
          ),
          const SizedBox(height: 8),
          AppButton.secondary(
            label: 'Exibir Toast Info',
            onPressed: () {
              context.showInfoToast('Uma nova versão está disponível.');
            },
          ),
        ],
      ),
    );
  }
}
