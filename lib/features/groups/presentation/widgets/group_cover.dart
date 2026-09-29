import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';

class GroupCover extends StatelessWidget {
  const GroupCover({super.key, required this.image, required this.name});

  final ImageProvider<Object>? image;
  final String name;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final spacing = context.spacing;

    return AspectRatio(
      aspectRatio: 1.9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(
            color: colors.surfaceSunken,
            child: image == null
                ? Center(
                    child: AppIcon(
                      icon: AppIcons.group,
                      size: spacing.s48,
                      color: colors.textMuted,
                    ),
                  )
                : Image(
                    image: image!,
                    fit: BoxFit.cover,
                    semanticLabel: l10n.groupCoverSemanticLabel(name),
                    errorBuilder: (_, _, _) => Center(
                      child: AppIcon(
                        icon: AppIcons.group,
                        size: spacing.s48,
                        color: colors.textMuted,
                      ),
                    ),
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
