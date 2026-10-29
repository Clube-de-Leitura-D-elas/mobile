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
    this.onOpen,
  });

  static const radius = 8.0;

  final MeetingPhotoEntity photo;
  final int index;
  final VoidCallback onReload;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);

    return Semantics(
      image: true,
      button: onOpen != null,
      label: onOpen == null
          ? context.l10n.meetingPhotoSemanticLabel(index + 1)
          : context.l10n.meetingPhotoOpenSemanticLabel(index + 1),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: GestureDetector(
          onTap: onOpen,
          child: LayoutBuilder(
            builder: (context, constraints) => Image.network(
              photo.url,
              fit: BoxFit.cover,
              cacheWidth: (constraints.maxWidth * pixelRatio).ceil(),
              loadingBuilder: (context, child, progress) =>
                  progress == null ? child : const MeetingPhotoPlaceholder(),
              errorBuilder: (context, error, stackTrace) => onOpen == null
                  ? MeetingPhotoPlaceholder(onReload: onReload)
                  : const MeetingPhotoPlaceholder(failed: true),
            ),
          ),
        ),
      ),
    );
  }
}

class MeetingPhotoPlaceholder extends StatelessWidget {
  const MeetingPhotoPlaceholder({
    super.key,
    this.onReload,
    this.failed = false,
  });

  final VoidCallback? onReload;

  /// Falhou, mas o toque fica com a miniatura (abre a foto em tela cheia).
  final bool failed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isLoading = onReload == null && !failed;
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
          : Icon(
              failed ? Icons.broken_image_outlined : Icons.refresh,
              color: colors.textMuted,
            ),
    );

    if (onReload != null) {
      content = Semantics(
        button: true,
        label: retryLabel,
        child: InkWell(onTap: onReload, child: content),
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
