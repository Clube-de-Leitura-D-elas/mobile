import 'package:flutter/material.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';

class MeetingPhotosMessage extends StatelessWidget {
  const MeetingPhotosMessage({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          message,
          style: context.typography.bodySmall.copyWith(
            color: context.colors.feedbackErrorDark,
          ),
        ),
        SizedBox(height: context.spacing.s8),
        AppButton.secondary(
          label: context.l10n.meetingPhotosRetryButton,
          size: AppButtonSize.sm,
          onPressed: onRetry,
        ),
      ],
    );
  }
}
