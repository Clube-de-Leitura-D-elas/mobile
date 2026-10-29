import 'package:flutter/material.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';

class MeetingTasksRaffleFooter extends StatelessWidget {
  const MeetingTasksRaffleFooter({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          spacing.s16,
          spacing.s8,
          spacing.s16,
          spacing.s16,
        ),
        child: AppButton.primary(
          key: const ValueKey('meeting_tasks_raffle'),
          label: context.l10n.rafflePreparationTitle,
          onPressed: onPressed,
        ),
      ),
    );
  }
}
