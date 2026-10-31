import 'package:flutter/material.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';

enum MeetingTaskCardState { active, done, locked }

/// Card de uma tarefa da anfitriã. Só no estado `active` mostra o botão de
/// ação e a borda em destaque.
class MeetingTaskCard extends StatelessWidget {
  const MeetingTaskCard({
    super.key,
    required this.title,
    required this.description,
    required this.state,
    required this.actionLabel,
    required this.onPressed,
    this.onEdit,
    this.editLabel,
    this.tag,
  });

  final String title;
  final String description;
  final MeetingTaskCardState state;
  final String actionLabel;
  final VoidCallback onPressed;

  final VoidCallback? onEdit;
  final String? editLabel;
  final String? tag;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final locked = state == MeetingTaskCardState.locked;
    final tag = this.tag;
    final onEdit = this.onEdit;
    final editLabel = this.editLabel;
    final isDone = state == MeetingTaskCardState.done;

    return AppCard(
      variant: state == MeetingTaskCardState.active
          ? CardVariant.highlighted
          : CardVariant.normal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: typography.bodyDefaultEmphasis.copyWith(
                    color: locked ? colors.textMuted : colors.textDefault,
                  ),
                ),
              ),
              if (isDone && onEdit != null && editLabel != null)
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  color: colors.textBrand,
                  tooltip: editLabel,
                  onPressed: onEdit,
                  visualDensity: VisualDensity.compact,
                ),
              if (isDone)
                Icon(
                  Icons.check_circle,
                  color: colors.feedbackSuccess,
                  semanticLabel: context.l10n.meetingTasksDoneSemantics,
                ),
              if (tag != null) AppTag(label: tag, variant: TagVariant.warning),
            ],
          ),
          SizedBox(height: spacing.s4),
          Text(
            description,
            style: typography.bodySmall.copyWith(color: colors.textMuted),
          ),
          if (state == MeetingTaskCardState.active) ...[
            SizedBox(height: spacing.s16),
            AppButton.primary(
              size: AppButtonSize.sm,
              label: actionLabel,
              onPressed: onPressed,
            ),
          ],
        ],
      ),
    );
  }
}
