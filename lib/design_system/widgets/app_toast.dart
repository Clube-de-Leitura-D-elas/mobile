import 'dart:async';

import 'package:flutter/material.dart';

import '../tokens/color_tokens.dart';
import '../tokens/spacing_tokens.dart';
import '../tokens/typography_tokens.dart';

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
                    color: colors.overlayScrim.withValues(
                      alpha: 0.08,
                    ), // <-- Atende a sugestão do Revisor
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

    _hideTimer = Timer(duration, () {
      dismiss();
    });
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
