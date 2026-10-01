import 'package:flutter/material.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/domain/entities/meeting_photo_entity.dart';
import 'package:mobile/features/groups/presentation/widgets/meeting_photos/meeting_photo_thumbnail.dart';
import 'package:mobile/features/groups/presentation/widgets/meeting_photos/meeting_photos_add_tile.dart';

class MeetingPhotosGrid extends StatelessWidget {
  const MeetingPhotosGrid({
    super.key,
    required this.photos,
    required this.showAddTile,
    required this.onAdd,
    required this.onReload,
  });

  static const _columns = 3;

  final List<MeetingPhotoEntity> photos;
  final bool showAddTile;
  final VoidCallback? onAdd;
  final VoidCallback onReload;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing.s8;

    return GridView.builder(
      key: const ValueKey('meeting-photos-grid'),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _columns,
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
      ),
      itemCount: photos.length + (showAddTile ? 1 : 0),
      itemBuilder: (context, index) => index < photos.length
          ? MeetingPhotoThumbnail(
              photo: photos[index],
              index: index,
              onReload: onReload,
            )
          : MeetingPhotosAddTile(onTap: onAdd),
    );
  }
}
