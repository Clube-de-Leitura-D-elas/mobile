import 'package:flutter/material.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/domain/entities/meeting_photo_entity.dart';

class MeetingPhotoThumbnail extends StatelessWidget {
  const MeetingPhotoThumbnail({
    super.key,
    required this.photo,
    required this.index,
  });

  static const radius = 8.0;

  final MeetingPhotoEntity photo;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: context.l10n.meetingPhotoSemanticLabel(index + 1),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.network(
          photo.url,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) => progress == null
              ? child
              : const MeetingPhotoPlaceholder(isLoading: true),
          errorBuilder: (context, error, stackTrace) =>
              const MeetingPhotoPlaceholder(isLoading: false),
        ),
      ),
    );
  }
}

class MeetingPhotoPlaceholder extends StatelessWidget {
  const MeetingPhotoPlaceholder({super.key, required this.isLoading});

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return ColoredBox(
      key: ValueKey(
        isLoading ? 'meeting-photo-loading' : 'meeting-photo-error',
      ),
      color: colors.surfaceSunken,
      child: Center(
        child: isLoading
            ? SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colors.textMuted,
                ),
              )
            : Icon(Icons.broken_image_outlined, color: colors.textMuted),
      ),
    );
  }
}
