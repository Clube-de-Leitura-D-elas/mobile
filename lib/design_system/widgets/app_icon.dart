import 'package:flutter/material.dart';
import 'package:jovial_svg/jovial_svg.dart';

import '../icons/app_icons.dart';

/// Design-system icon. Monochromatic when [color] is set: [ColorFiltered]
/// with [BlendMode.srcIn] replaces every pixel of the compiled `.si`.
/// Omit [color] to keep the asset colors as compiled.
class AppIcon extends StatelessWidget {
  const AppIcon({
    super.key,
    required this.icon,
    required this.size,
    this.color,
    this.backgroundColor,
    this.padding,
    this.borderRadius,
  });

  final AppIconAsset icon;
  final Color? color;
  final double size;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      clipBehavior: borderRadius == null ? Clip.none : Clip.antiAlias,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
      ),
      child: _TintedSiIcon(icon: icon, color: color, size: size),
    );
  }
}

class _TintedSiIcon extends StatelessWidget {
  const _TintedSiIcon({
    required this.icon,
    required this.color,
    required this.size,
  });

  static final _cache = ScalableImageCache(size: 12);

  final AppIconAsset icon;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final image = ScalableImageWidget.fromSISource(
      si: ScalableImageSource.fromSI(
        DefaultAssetBundle.of(context),
        icon.assetPath,
      ),
      cache: _cache,
      fit: BoxFit.contain,
    );

    return SizedBox(
      width: size,
      height: size,
      child: color == null
          ? image
          : ColorFiltered(
              colorFilter: ColorFilter.mode(color!, BlendMode.srcIn),
              child: image,
            ),
    );
  }
}
