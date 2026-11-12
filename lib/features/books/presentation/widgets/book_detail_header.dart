import 'dart:ui' show ImageFilter;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/home/presentation/routes/home_routes.dart';

class BookDetailHeader extends StatelessWidget {
  const BookDetailHeader({
    super.key,
    required this.title,
    required this.author,
    required this.status,
    this.coverUrl,
    this.rating,
    this.onBackPressed,
    this.onStatusTap,
    this.isStatusLoading = false,
  });

  final String title;
  final String author;
  final String? coverUrl;
  final double? rating;
  final ReadingStatusChipState status;
  final VoidCallback? onBackPressed;
  final VoidCallback? onStatusTap;
  final bool isStatusLoading;

  static const double backButtonSize = 48;

  static const double coverOverlap = 88;

  static const double blurSigma = 12;

  static const double scrimOpacity = 0.7;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;
    final rating = this.rating;
    final coverTop =
        MediaQuery.paddingOf(context).top +
        spacing.s8 +
        backButtonSize +
        spacing.s8;
    final textStart = spacing.s16 + AppBookCover.headerSize.width + spacing.s16;

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Positioned.fill(child: _BlurredBackground(url: coverUrl)),
                Padding(
                  padding: EdgeInsetsDirectional.only(
                    start: textStart,
                    end: spacing.s16,
                    top: coverTop,
                    bottom: spacing.s16,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: coverOverlap - spacing.s16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Semantics(
                          header: true,
                          child: Text(
                            title,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: typography.headingH2.copyWith(
                              color: colors.textOnBrand,
                            ),
                          ),
                        ),
                        if (author.isNotEmpty) ...[
                          const Gap4(),
                          Text(
                            context.l10n.bookDetailWrittenBy(author),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: typography.bodySmall.copyWith(
                              color: colors.textOnBrand,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsetsDirectional.only(
                start: textStart,
                end: spacing.s16,
                top: spacing.s12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppStarRating.display(
                    rating: rating ?? 0,
                    semanticLabel: rating == null
                        ? context.l10n.bookDetailNoRatings
                        : null,
                  ),
                  const Gap8(),
                  AppReadingStatusChip(
                    state: status,
                    onTap: onStatusTap,
                    isLoading: isStatusLoading,
                  ),
                ],
              ),
            ),
          ],
        ),
        PositionedDirectional(
          top: coverTop,
          start: spacing.s16,
          child: AppBookCover(
            imageUrl: coverUrl,
            size: AppBookCoverSize.header,
          ),
        ),
        PositionedDirectional(
          top: MediaQuery.paddingOf(context).top + spacing.s8,
          start: spacing.s8,
          child: _BackButton(onPressed: onBackPressed),
        ),
      ],
    );
  }
}

class _BlurredBackground extends StatelessWidget {
  const _BlurredBackground({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final url = this.url;
    final fallback = ColoredBox(color: colors.actionPrimary);

    return ExcludeSemantics(
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (url == null || url.isEmpty)
            fallback
          else
            ClipRect(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(
                  sigmaX: BookDetailHeader.blurSigma,
                  sigmaY: BookDetailHeader.blurSigma,
                  tileMode: TileMode.clamp,
                ),
                child: CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => fallback,
                  errorWidget: (_, _, _) => fallback,
                ),
              ),
            ),
          ColoredBox(
            color: colors.overlayScrim.withValues(
              alpha: BookDetailHeader.scrimOpacity,
            ),
          ),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    return IconButton(
      tooltip: context.l10n.back,
      onPressed:
          onPressed ??
          () => context.canPop() ? context.pop() : context.go(HomeRoutes.home),
      constraints: const BoxConstraints.tightFor(
        width: BookDetailHeader.backButtonSize,
        height: BookDetailHeader.backButtonSize,
      ),
      padding: EdgeInsets.zero,
      icon: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaceDefault.withValues(alpha: 0.7),
          shape: BoxShape.circle,
        ),
        child: Padding(
          padding: EdgeInsets.all(spacing.s4),
          child: Icon(
            Icons.chevron_left,
            size: spacing.s24 + spacing.s4,
            color: colors.textDefault,
          ),
        ),
      ),
    );
  }
}
