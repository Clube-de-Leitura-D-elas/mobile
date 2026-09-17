import 'package:flutter/material.dart';
import 'package:mobile/design_system/widgets/app_toast.dart';

extension ToastExtension on BuildContext {
  void showToast(
    String message, {
    AppToastType type = AppToastType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    AppToast.show(this, message: message, type: type, duration: duration);
  }

  void showSuccessToast(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    showToast(message, type: AppToastType.success, duration: duration);
  }

  void showErrorToast(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    showToast(message, type: AppToastType.error, duration: duration);
  }

  void showWarningToast(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    showToast(message, type: AppToastType.warning, duration: duration);
  }

  void showInfoToast(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    showToast(message, type: AppToastType.info, duration: duration);
  }
}
