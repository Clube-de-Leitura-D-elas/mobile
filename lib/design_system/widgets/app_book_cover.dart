import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mobile/design_system/icons/app_icons.dart';
import 'package:mobile/design_system/tokens/color_tokens.dart';
import 'package:mobile/design_system/tokens/spacing_tokens.dart';

import 'app_card.dart';
import 'app_icon.dart';

enum AppBookCoverSize { grid, list, header }

/// Capa de livro com placeholder quando não há imagem ou ela falha.
///
/// [AppBookCoverSize.grid] ocupa a largura disponível mantendo a proporção da
/// capa; o pai precisa limitar a largura (por exemplo [SizedBox] ou coluna de
/// grid). Os demais tamanhos são fixos. Sem [semanticLabel] a capa é tratada
/// como decoração, porque o título do livro costuma estar ao lado.
class AppBookCover extends StatelessWidget {
  const AppBookCover({
    super.key,
    this.imageUrl,
    this.size = AppBookCoverSize.list,
    this.semanticLabel,
  });

  final String? imageUrl;
  final AppBookCoverSize size;
  final String? semanticLabel;

  static const Size listSize = Size(80, 112);
  static const Size headerSize = Size(107, 157);
  static const double gridAspectRatio = 114 / 141;
  static const double borderRadius = AppCard.borderRadius / 2;

  @override
  Widget build(BuildContext context) {
    final cover = ExcludeSemantics(
      child: _AppBookCoverFrame(
        size: size,
        child: _AppBookCoverImage(imageUrl: imageUrl),
      ),
    );

    if (semanticLabel == null) {
      return cover;
    }
    return Semantics(image: true, label: semanticLabel, child: cover);
  }
}

class _AppBookCoverFrame extends StatelessWidget {
  const _AppBookCoverFrame({required this.size, required this.child});

  final AppBookCoverSize size;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final clipped = ClipRRect(
      borderRadius: BorderRadius.circular(AppBookCover.borderRadius),
      child: child,
    );

    return switch (size) {
      AppBookCoverSize.grid => AspectRatio(
        aspectRatio: AppBookCover.gridAspectRatio,
        child: clipped,
      ),
      AppBookCoverSize.list => SizedBox.fromSize(
        size: AppBookCover.listSize,
        child: clipped,
      ),
      AppBookCoverSize.header => SizedBox.fromSize(
        size: AppBookCover.headerSize,
        child: clipped,
      ),
    };
  }
}

class _AppBookCoverImage extends StatelessWidget {
  const _AppBookCoverImage({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    if (url == null || url.isEmpty) {
      return const _AppBookCoverPlaceholder();
    }

    return CachedNetworkImage(
      imageUrl: url,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      errorWidget: (_, _, _) => const _AppBookCoverPlaceholder(),
    );
  }
}

class _AppBookCoverPlaceholder extends StatelessWidget {
  const _AppBookCoverPlaceholder();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return ColoredBox(
      color: colors.surfaceSunken,
      child: Center(
        child: AppIcon(
          icon: AppIcons.book,
          size: context.spacing.s24,
          color: colors.textMuted,
        ),
      ),
    );
  }
}
