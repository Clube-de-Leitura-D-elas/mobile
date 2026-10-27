import 'package:flutter/material.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';

class MeetingTasksErrorView extends StatelessWidget {
  const MeetingTasksErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: EdgeInsets.all(context.spacing.s24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: context.typography.bodyDefault.copyWith(
              color: context.colors.feedbackError,
            ),
          ),
          SizedBox(height: context.spacing.s16),
          AppButton.secondary(
            size: AppButtonSize.sm,
            label: context.l10n.meetingTasksRetry,
            onPressed: onRetry,
          ),
        ],
      ),
    ),
  );
}
