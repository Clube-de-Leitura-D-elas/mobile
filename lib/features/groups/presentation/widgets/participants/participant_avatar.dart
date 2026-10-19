import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mobile/features/groups/presentation/widgets/participants/participant_avatar_placeholder.dart';

/// Circular participant photo with a placeholder when there is no photo or
/// the image fails to load. Decorative: the name next to it carries meaning.
class ParticipantAvatar extends StatelessWidget {
  final String? photoUrl;

  const ParticipantAvatar({super.key, required this.photoUrl});

  static const double size = 60;

  @override
  Widget build(BuildContext context) {
    final url = photoUrl;
    final cacheSize = (size * MediaQuery.devicePixelRatioOf(context)).round();

    return ExcludeSemantics(
      child: ClipOval(
        child: SizedBox.square(
          dimension: size,
          child: url == null
              ? const ParticipantAvatarPlaceholder()
              : CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.cover,
                  memCacheWidth: cacheSize,
                  memCacheHeight: cacheSize,
                  placeholder: (context, _) =>
                      const ParticipantAvatarPlaceholder(),
                  errorWidget: (context, _, _) =>
                      const ParticipantAvatarPlaceholder(),
                ),
        ),
      ),
    );
  }
}
