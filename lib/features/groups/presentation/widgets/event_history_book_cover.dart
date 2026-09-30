import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/presentation/widgets/event_history_book_cover_dimensions.dart';
import 'package:mobile/features/groups/presentation/widgets/event_history_book_cover_placeholder.dart';

class EventHistoryBookCover extends StatelessWidget {
  const EventHistoryBookCover({super.key, this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (imageUrl == null || imageUrl!.isEmpty) {
      return EventHistoryBookCoverPlaceholder(color: colors.surfaceSunken);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppCard.borderRadius / 2),
      child: CachedNetworkImage(
        imageUrl: imageUrl!,
        width: EventHistoryBookCoverDimensions.width,
        height: EventHistoryBookCoverDimensions.height,
        fit: BoxFit.cover,
        errorWidget: (_, _, _) =>
            EventHistoryBookCoverPlaceholder(color: colors.surfaceSunken),
      ),
    );
  }
}
