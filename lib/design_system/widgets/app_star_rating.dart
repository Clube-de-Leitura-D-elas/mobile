import 'package:flutter/material.dart';

import '../tokens/color_tokens.dart';

/// Sizes for [AppStarRating.display].
enum AppStarRatingSize {
  /// Small variant – used in review lists (e.g. CLU-267). 16×16 px stars.
  sm(starSize: 16.0, gap: 4.0),

  /// Medium variant – used in the book header. 20×20 px stars.
  md(starSize: 20.0, gap: 4.0);

  const AppStarRatingSize({required this.starSize, required this.gap});

  final double starSize;
  final double gap;
}

/// Star rating widget with two modes.
///
/// **Display mode** ([AppStarRating.display]): read-only, supports half-star
/// increments and two sizes (`sm` / `md`). Wrap with a semantic label for
/// accessibility (e.g. "4,5 de 5 estrelas").
///
/// **Input mode** ([AppStarRating.input]): five tappable stars. Only integer
/// values (1–5) are emitted via [onChanged]. Pass `onChanged: null` for a
/// read-only interactive appearance.
///
/// Colors default to the design-system tokens:
/// - filled  → [AppColorTokens.actionPrimary] (primary pink)
/// - empty   → [AppColorTokens.borderStrong]  (outline)
class AppStarRating extends StatelessWidget {
  // ── Display ──────────────────────────────────────────────────────────────

  /// Creates a read-only star rating that supports half-star fractions.
  const AppStarRating.display({
    super.key,
    required this.rating,
    this.size = AppStarRatingSize.md,
    this.maxStars = 5,
    this.filledColor,
    this.emptyColor,
    this.semanticLabel,
  }) : _isInput = false,
       onChanged = null,
       _inputRating = 0,
       _inputStarSize = 0,
       _inputGap = 0;

  // ── Input ─────────────────────────────────────────────────────────────────

  /// Creates five tappable stars for collecting an integer rating (1–5).
  ///
  /// Pass `onChanged: null` to disable interaction.
  const AppStarRating.input({
    super.key,
    required int rating,
    required this.onChanged,
    this.maxStars = 5,
    double starSize = 36.0,
    double spacing = 8.0,
    this.filledColor,
    this.emptyColor,
  }) : _isInput = true,
       _inputRating = rating,
       _inputStarSize = starSize,
       _inputGap = spacing,
       rating = 0,
       size = AppStarRatingSize.md,
       semanticLabel = null;

  // ── Shared fields ─────────────────────────────────────────────────────────

  final bool _isInput;
  final int maxStars;
  final Color? filledColor;
  final Color? emptyColor;

  // Display-only
  final double rating;
  final AppStarRatingSize size;
  final String? semanticLabel;

  // Input-only
  final int _inputRating;
  final double _inputStarSize;
  final double _inputGap;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    return _isInput ? _InputStarRating(this) : _DisplayStarRating(this);
  }
}

// ── Display ────────────────────────────────────────────────────────────────

class _DisplayStarRating extends StatelessWidget {
  const _DisplayStarRating(this.widget);

  final AppStarRating widget;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    final filled = widget.filledColor ?? colors.actionPrimary;
    final empty = widget.emptyColor ?? colors.borderStrong;
    final starSize = widget.size.starSize;
    final gap = widget.size.gap;

    final label =
        widget.semanticLabel ?? _defaultLabel(widget.rating, widget.maxStars);

    return Semantics(
      label: label,
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(widget.maxStars, (i) {
            final starValue = i + 1;
            Widget star;

            if (widget.rating >= starValue) {
              // Full star
              star = Icon(Icons.star_rounded, size: starSize, color: filled);
            } else if (widget.rating >= starValue - 0.5) {
              // Half star
              star = _HalfStar(size: starSize, filled: filled, empty: empty);
            } else {
              // Empty star
              star = Icon(
                Icons.star_outline_rounded,
                size: starSize,
                color: empty,
              );
            }

            return Padding(
              padding: EdgeInsets.only(right: i < widget.maxStars - 1 ? gap : 0),
              child: star,
            );
          }),
        ),
      ),
    );
  }

  static String _defaultLabel(double rating, int maxStars) {
    final formatted = rating == rating.floorToDouble()
        ? rating.toInt().toString()
        : rating.toStringAsFixed(1).replaceAll('.', ',');
    return '$formatted de $maxStars estrelas';
  }
}

/// Paints a half-filled star: left half filled, right half outlined.
class _HalfStar extends StatelessWidget {
  const _HalfStar({
    required this.size,
    required this.filled,
    required this.empty,
  });

  final double size;
  final Color filled;
  final Color empty;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Background: full outline star
          Icon(Icons.star_outline_rounded, size: size, color: empty),
          // Foreground: clip to left half → filled star
          ClipRect(
            clipper: _LeftHalfClipper(),
            child: Icon(Icons.star_rounded, size: size, color: filled),
          ),
        ],
      ),
    );
  }
}

class _LeftHalfClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) => Rect.fromLTWH(0, 0, size.width / 2, size.height);

  @override
  bool shouldReclip(_LeftHalfClipper oldClipper) => false;
}

// ── Input ──────────────────────────────────────────────────────────────────

class _InputStarRating extends StatelessWidget {
  const _InputStarRating(this.widget);

  final AppStarRating widget;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    final filled = widget.filledColor ?? colors.actionPrimary;
    final empty = widget.emptyColor ?? colors.borderStrong;
    final starSize = widget._inputStarSize;
    final gap = widget._inputGap;
    final isEnabled = widget.onChanged != null;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.maxStars, (i) {
        final starValue = i + 1;
        final isFilled = widget._inputRating >= starValue;

        return Padding(
          padding: EdgeInsets.only(
            right: i < widget.maxStars - 1 ? gap : 0,
          ),
          child: Semantics(
            button: true,
            enabled: isEnabled,
            selected: isFilled,
            label: '$starValue de ${widget.maxStars} estrelas',
            onTap: isEnabled ? () => widget.onChanged!(starValue) : null,
            child: ExcludeSemantics(
              child: _StarButton(
                starValue: starValue,
                isFilled: isFilled,
                starSize: starSize,
                filled: filled,
                empty: empty,
                isEnabled: isEnabled,
                splashColor: colors.surfaceBrandSoft,
                onTap: isEnabled ? () => widget.onChanged!(starValue) : null,
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _StarButton extends StatelessWidget {
  const _StarButton({
    required this.starValue,
    required this.isFilled,
    required this.starSize,
    required this.filled,
    required this.empty,
    required this.isEnabled,
    required this.splashColor,
    required this.onTap,
  });

  final int starValue;
  final bool isFilled;
  final double starSize;
  final Color filled;
  final Color empty;
  final bool isEnabled;
  final Color splashColor;
  final VoidCallback? onTap;

  /// Minimum tap target (48 dp) so the widget is comfortable to tap.
  static const double _hitSize = 48.0;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_hitSize / 2),
        splashColor: isEnabled ? splashColor : Colors.transparent,
        highlightColor: isEnabled
            ? splashColor.withValues(alpha: 0.35)
            : Colors.transparent,
        child: SizedBox(
          width: _hitSize,
          height: _hitSize,
          child: Center(
            child: Icon(
              isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
              size: starSize,
              color: isFilled ? filled : empty,
            ),
          ),
        ),
      ),
    );
  }
}
