import 'dart:async';

import 'package:flutter/material.dart';

import '../tokens/color_tokens.dart';
import '../tokens/spacing_tokens.dart';
import '../tokens/typography_tokens.dart';

/// Visual variants available for [AppToast].
enum AppToastType {
  success,
  error,
  warning,
  info,
}

/// Temporary feedback message for the Design System.
///
/// The visual component itself is stateless. The [show] helper handles
/// temporary presentation through the app's [Overlay].
class AppToast extends StatelessWidget {
  const AppToast({
    super.key,
    required this.message,
    this.type = AppToastType.info,
  });

  final String message;
  final AppToastType type;

  /// Displays a toast above the current screen.
  ///
  /// The toast is removed automatically after [duration].
  static void show(
    BuildContext context, {
    required String message,
    AppToastType type = AppToastType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.maybeOf(
      context,
      rootOverlay: true,
    );

    if (overlay == null) {
      return;
    }

    late final OverlayEntry entry;

    entry = OverlayEntry(
      builder: (overlayContext) {
        return Positioned(
          top: MediaQuery.paddingOf(overlayContext).top + 16.0,
          left: 24.0,
          right: 24.0,
          child: SafeArea(
            bottom: false,
            child: Material(
              color: Colors.transparent,
              child: AppToast(
                message: message,
                type: type,
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(entry);

    Timer(duration, () {
      if (entry.mounted) {
        entry.remove();
      }
    });
  }

  IconData get _icon {
    switch (type) {
      case AppToastType.success:
        return Icons.check_circle_outline;
      case AppToastType.error:
        return Icons.cancel_outlined;
      case AppToastType.warning:
        return Icons.warning_amber_outlined;
      case AppToastType.info:
        return Icons.info_outline;
    }
  }

  Color _backgroundColor(AppColorTokens colors) {
    switch (type) {
      case AppToastType.success:
        return colors.feedbackSuccessLight;
      case AppToastType.error:
        return colors.feedbackErrorLight;
      case AppToastType.warning:
        return colors.feedbackWarningLight;
      case AppToastType.info:
        return colors.feedbackInfoLight;
    }
  }

  Color _foregroundColor(AppColorTokens colors) {
    switch (type) {
      case AppToastType.success:
        return colors.feedbackSuccessDark;
      case AppToastType.error:
        return colors.feedbackErrorDark;
      case AppToastType.warning:
        return colors.feedbackWarningDark;
      case AppToastType.info:
        return colors.feedbackInfoDark;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.text;
    final spacing = context.spacing;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDark
        ? _darkBackgroundColor(colors)
        : _backgroundColor(colors);

    final foregroundColor = isDark
        ? colors.textOnBrand
        : _foregroundColor(colors);

    return Semantics(
      liveRegion: true,
      container: true,
      label: message,
      child: Container(
        constraints: const BoxConstraints(
          minHeight: 48.0,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: spacing.s16,
          vertical: spacing.s12,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: const [
            BoxShadow(
              blurRadius: 12.0,
              offset: Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              _icon,
              size: 20.0,
              color: foregroundColor,
            ),
            SizedBox(width: spacing.s8),
            Expanded(
              child: Text(
                message,
                style: typography.bodySmall.copyWith(
                  color: foregroundColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _darkBackgroundColor(AppColorTokens colors) {
    switch (type) {
      case AppToastType.success:
        return colors.feedbackSuccessLight;
      case AppToastType.error:
        return colors.feedbackErrorLight;
      case AppToastType.warning:
        return colors.feedbackWarningLight;
      case AppToastType.info:
        return colors.feedbackInfoLight;
    }
  }
}