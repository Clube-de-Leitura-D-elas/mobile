import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/design_system/design_system.dart';

class AppGroupAvatar extends StatelessWidget {
  final String? photoUrl;
  final double diameter;

  const AppGroupAvatar({
    super.key,
    required this.photoUrl,
    this.diameter = size,
  });

  static const double size = 56;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final url = photoUrl;

    Widget placeholder() => ColoredBox(
      color: colors.surfaceSunken,
      child: Icon(
        Icons.groups_outlined,
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
