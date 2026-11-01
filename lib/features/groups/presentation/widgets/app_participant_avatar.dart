import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mobile/design_system/design_system.dart';

class AppParticipantAvatar extends StatelessWidget {
  final String? photoUrl;
  final double diameter;

  const AppParticipantAvatar({
    super.key,
    required this.photoUrl,
    this.diameter = size,
  });

  /// Diâmetro padrão, usado nas listas de participantes.
  static const double size = 56;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final url = photoUrl;

    Widget placeholder() => ColoredBox(
      color: colors.surfaceSunken,
      child: Icon(
        Icons.person_outline,
        // 24 no diâmetro padrão, crescendo junto com o avatar.
        size: diameter * 3 / 7,
        color: colors.textMuted,
      ),
    );

    return ClipOval(
      child: SizedBox(
        width: diameter,
        height: diameter,
        child: url == null || url.isEmpty
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
