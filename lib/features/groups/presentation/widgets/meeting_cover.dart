import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';

class MeetingCover extends StatelessWidget {
  const MeetingCover({super.key, required this.image, required this.title});

  final ImageProvider<Object>? image;
  final String title;

  static const double aspectRatio = 1.9;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final spacing = context.spacing;

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(
            color: colors.surfaceSunken,
            child: image == null
                ? const _MeetingCoverPlaceholder()
                : Image(
                    image: image!,
                    fit: BoxFit.cover,
                    semanticLabel: l10n.meetingCoverSemanticLabel(title),
                    errorBuilder: (_, _, _) => const _MeetingCoverPlaceholder(),
                  ),
          ),
          SafeArea(
            bottom: false,
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.all(spacing.s12),
                child: Material(
                  color: colors.surfaceDefault,
                  shape: const CircleBorder(),
                  child: IconButton(
                    tooltip: l10n.back,
                    icon: const Icon(Icons.arrow_back),
                    color: colors.textDefault,
                    onPressed: () => context.pop(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MeetingCoverPlaceholder extends StatelessWidget {
  const _MeetingCoverPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const ValueKey('meeting-cover-placeholder'),
      child: AppIcon(
        icon: AppIcons.camera,
        size: context.spacing.s48,
        color: context.colors.textMuted,
      ),
    );
  }
}
