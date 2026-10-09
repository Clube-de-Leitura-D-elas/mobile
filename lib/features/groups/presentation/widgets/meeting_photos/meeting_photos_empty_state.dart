import 'package:flutter/material.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/presentation/widgets/meeting_photos/meeting_photos_dashed_border.dart';

class MeetingPhotosEmptyState extends StatelessWidget {
  const MeetingPhotosEmptyState({super.key, required this.onTap});

  static const _radius = 12.0;
  static const _height = 120.0;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final foreground = onTap == null
        ? colors.actionDisabledFg
        : colors.textBrand;

    return MeetingPhotosDashedBorder(
      color: colors.borderBrand,
      radius: _radius,
      child: Material(
        color: colors.surfaceBrandSoft.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(_radius),
        child: Semantics(
          button: true,
          enabled: onTap != null,
          label: context.l10n.meetingPhotosAdd,
          child: InkWell(
            key: const ValueKey('meeting-photos-empty-state'),
            borderRadius: BorderRadius.circular(_radius),
            onTap: onTap,
            child: SizedBox(
              height: _height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppIcon(icon: AppIcons.camera, size: 32, color: foreground),
                  SizedBox(height: spacing.s8),
                  Text(
                    context.l10n.meetingPhotosAdd,
                    style: context.typography.bodyDefaultEmphasis.copyWith(
                      color: foreground,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
