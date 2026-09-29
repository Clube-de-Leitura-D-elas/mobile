import 'package:flutter/material.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/presentation/widgets/event_history_book_cover_dimensions.dart';

class EventHistoryBookCoverPlaceholder extends StatelessWidget {
  const EventHistoryBookCoverPlaceholder({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: EventHistoryBookCoverDimensions.width,
      height: EventHistoryBookCoverDimensions.height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppCard.borderRadius / 2),
      ),
      child: AppIcon(
        icon: AppIcons.book,
        size: context.spacing.s24,
        color: context.colors.textMuted,
      ),
    );
  }
}
