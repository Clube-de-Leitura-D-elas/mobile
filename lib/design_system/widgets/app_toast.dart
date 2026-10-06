import 'package:flutter/material.dart';
import 'package:mobile/design_system/design_system.dart';

/// Extension method on [BuildContext] to present standardized Toast / SnackBar notifications.
extension AppToastExtension on BuildContext {
  /// Displays a floating, neutral design-system styled toast notification.
  void showAppToast(String message) {
    final colors = this.colors;
    final typography = text;

    final messenger = ScaffoldMessenger.of(this);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colors.surfaceDefault,
        elevation: 4,
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(color: colors.borderDefault, width: 1.0),
        ),
        content: Text(
          message,
          style: typography.bodyDefault.copyWith(
            color: colors.textDefault,
          ),
        ),
      ),
    );
  }
}
