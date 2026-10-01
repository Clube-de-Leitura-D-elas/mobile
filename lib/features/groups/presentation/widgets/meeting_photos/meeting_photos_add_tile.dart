import 'package:flutter/material.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/presentation/widgets/meeting_photos/meeting_photo_thumbnail.dart';
import 'package:mobile/features/groups/presentation/widgets/meeting_photos/meeting_photos_dashed_border.dart';

class MeetingPhotosAddTile extends StatelessWidget {
  const MeetingPhotosAddTile({super.key, required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final borderRadius = BorderRadius.circular(MeetingPhotoThumbnail.radius);

    return Semantics(
      button: true,
      label: context.l10n.meetingPhotosAddMoreSemanticLabel,
      child: MeetingPhotosDashedBorder(
        color: colors.borderBrand,
        radius: MeetingPhotoThumbnail.radius,
        child: Material(
          color: Colors.transparent,
          borderRadius: borderRadius,
          child: InkWell(
            key: const ValueKey('meeting-photos-add-tile'),
            borderRadius: borderRadius,
            onTap: onTap,
            child: Center(
              child: AppIcon(
                icon: AppIcons.plus,
                size: 24,
                color: onTap == null
                    ? colors.actionDisabledFg
                    : colors.textBrand,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
