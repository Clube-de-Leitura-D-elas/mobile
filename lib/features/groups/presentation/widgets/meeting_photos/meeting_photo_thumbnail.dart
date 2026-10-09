import 'package:flutter/material.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/domain/entities/meeting_photo_entity.dart';
import 'package:mobile/l10n/app_localizations.dart';

class MeetingPhotoThumbnail extends StatelessWidget {
  const MeetingPhotoThumbnail({
    super.key,
    required this.photo,
    required this.index,
    required this.onReload,
  });

  static const radius = 8.0;

  final MeetingPhotoEntity photo;
  final int index;
  final VoidCallback onReload;

  @override
  Widget build(BuildContext context) {
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);

    return Semantics(
      image: true,
      label: context.l10n.meetingPhotoSemanticLabel(index + 1),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: LayoutBuilder(
          builder: (context, constraints) => Image.network(
            photo.url,
            fit: BoxFit.cover,
            cacheWidth: (constraints.maxWidth * pixelRatio).ceil(),
            loadingBuilder: (context, child, progress) =>
                progress == null ? child : const MeetingPhotoPlaceholder(),
            errorBuilder: (context, error, stackTrace) =>
                MeetingPhotoPlaceholder(onReload: onReload),
          ),
        ),
      ),
    );
  }
}


class MeetingPhotoPlaceholder extends StatelessWidget {
  const MeetingPhotoPlaceholder({super.key, this.onReload});

  final VoidCallback? onReload;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isLoading = onReload == null;
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations);
    final retryLabel = l10n?.meetingPhotosRetryButton ?? 'Tentar novamente';

    Widget content = Center(
      child: isLoading
          ? SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colors.textMuted,
              ),
            )
          : Icon(Icons.refresh, color: colors.textMuted),
    );

    if (!isLoading) {
      content = Semantics(
        button: true,
        label: retryLabel,
        child: InkWell(
          onTap: onReload,
          child: content,
        ),
      );
    }

    return Material(
      key: ValueKey(
        isLoading ? 'meeting-photo-loading' : 'meeting-photo-error',
      ),
      color: colors.surfaceSunken,
      child: content,
    );
  }
}
