import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mobile/design_system/design_system.dart';

class AppGroupAvatar extends StatelessWidget {
  final String? photoUrl;

  const AppGroupAvatar({super.key, required this.photoUrl});

  static const double size = 56;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final url = photoUrl;

    Widget placeholder() => ColoredBox(
      color: colors.surfaceSunken,
      child: Icon(Icons.groups_outlined, color: colors.textMuted),
    );

    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: url == null
            ? placeholder()
            : CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (context, _) => placeholder(),
                errorWidget: (context, _, _) => placeholder(),
              ),
      ),
    );
  }
}
