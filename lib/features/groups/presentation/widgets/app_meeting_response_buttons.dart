import 'package:flutter/material.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';

enum _Choice { confirmed, declined }

class AppMeetingResponseButtons extends StatefulWidget {
  const AppMeetingResponseButtons({
    super.key,
    this.onConfirmPresence,
    this.onDeclinePresence,
  });

  final VoidCallback? onConfirmPresence;
  final VoidCallback? onDeclinePresence;

  @override
  State<AppMeetingResponseButtons> createState() =>
      _AppMeetingResponseButtonsState();
}

class _AppMeetingResponseButtonsState extends State<AppMeetingResponseButtons> {
  _Choice? _choice;

  void _handleConfirm() {
    setState(() => _choice = _Choice.confirmed);
    widget.onConfirmPresence?.call();
  }

  void _handleDecline() {
    setState(() => _choice = _Choice.declined);
    widget.onDeclinePresence?.call();
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final l10n = context.l10n;

    Widget content;

    switch (_choice) {
      case null:
        content = Row(
          children: [
            Expanded(
              child: AppButton.secondary(
                size: AppButtonSize.sm,
                label: l10n.groupDeclineMeetingButton,
                onPressed: _handleDecline,
              ),
            ),
            SizedBox(width: spacing.s8),
            Expanded(
              child: AppButton.primary(
                size: AppButtonSize.sm,
                label: l10n.groupConfirmMeetingButton,
                onPressed: _handleConfirm,
              ),
            ),
          ],
        );
        break;

      case _Choice.confirmed:
        content = SizedBox(
          width: double.infinity,
          child: AppButton.secondary(
            size: AppButtonSize.sm,
            label: l10n.groupDeclineMeetingButton,
            onPressed: _handleDecline,
          ),
        );
        break;

      case _Choice.declined:
        content = SizedBox(
          width: double.infinity,
          child: AppButton.primary(
            size: AppButtonSize.sm,
            label: l10n.groupConfirmMeetingButton,
            onPressed: _handleConfirm,
          ),
        );
        break;
    }

    return Padding(padding: const EdgeInsets.only(bottom: 2.0), child: content);
  }
}
