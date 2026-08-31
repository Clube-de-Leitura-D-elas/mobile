import 'package:flutter/material.dart';

/// Design system typography tokens for Clube de Leitura D'Elas.
///
/// Based on Nunito typography scale with 16px base size.
/// All 13 text styles strictly follow 4pt line-height grid.
@immutable
class AppTypographyTokens extends ThemeExtension<AppTypographyTokens> {
  const AppTypographyTokens({
    required this.display,
    required this.headingH1,
    required this.headingH2,
    required this.headingH3,
    required this.bodyLarge,
    required this.bodyDefault,
    required this.bodyDefaultEmphasis,
    required this.bodySmall,
    required this.bodySmallEmphasis,
    required this.labelButton,
    required this.labelTag,
    required this.caption,
    required this.overline,
  });

  // --- Display & Headings ---
  final TextStyle display;
  final TextStyle headingH1;
  final TextStyle headingH2;
  final TextStyle headingH3;

  // --- Body ---
  final TextStyle bodyLarge;
  final TextStyle bodyDefault;
  final TextStyle bodyDefaultEmphasis;
  final TextStyle bodySmall;
  final TextStyle bodySmallEmphasis;

  // --- Labels, Caption & Overline ---
  final TextStyle labelButton;
  final TextStyle labelTag;
  final TextStyle caption;
  final TextStyle overline;

  static const String _fontFamily = 'Nunito';

  /// Standard typography tokens based on Figma specs.
  static const standard = AppTypographyTokens(
    display: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 40.0,
      height: 48.0 / 40.0,
      fontWeight: FontWeight.w700,
    ),
    headingH1: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 32.0,
      height: 40.0 / 32.0,
      fontWeight: FontWeight.w700,
    ),
    headingH2: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 24.0,
      height: 32.0 / 24.0,
      fontWeight: FontWeight.w700,
    ),
    headingH3: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 20.0,
      height: 28.0 / 20.0,
      fontWeight: FontWeight.w700,
    ),
    bodyLarge: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 18.0,
      height: 28.0 / 18.0,
      fontWeight: FontWeight.w400,
    ),
    bodyDefault: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 16.0,
      height: 24.0 / 16.0,
      fontWeight: FontWeight.w400,
    ),
    bodyDefaultEmphasis: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 16.0,
      height: 24.0 / 16.0,
      fontWeight: FontWeight.w600,
    ),
    bodySmall: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 14.0,
      height: 20.0 / 14.0,
      fontWeight: FontWeight.w400,
    ),
    bodySmallEmphasis: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 14.0,
      height: 20.0 / 14.0,
      fontWeight: FontWeight.w600,
    ),
    labelButton: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 16.0,
      height: 24.0 / 16.0,
      fontWeight: FontWeight.w700,
    ),
    labelTag: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 12.0,
      height: 16.0 / 12.0,
      fontWeight: FontWeight.w700,
    ),
    caption: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 12.0,
      height: 16.0 / 12.0,
      fontWeight: FontWeight.w400,
    ),
    overline: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 12.0,
      height: 16.0 / 12.0,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.96, // 12px * 0.08em
    ),
  );

  /// Helper getter to retrieve typography tokens directly from BuildContext.
  static AppTypographyTokens of(BuildContext context) {
    return Theme.of(context).extension<AppTypographyTokens>() ??
        AppTypographyTokens.standard;
  }

  @override
  AppTypographyTokens copyWith({
    TextStyle? display,
    TextStyle? headingH1,
    TextStyle? headingH2,
    TextStyle? headingH3,
    TextStyle? bodyLarge,
    TextStyle? bodyDefault,
    TextStyle? bodyDefaultEmphasis,
    TextStyle? bodySmall,
    TextStyle? bodySmallEmphasis,
    TextStyle? labelButton,
    TextStyle? labelTag,
    TextStyle? caption,
    TextStyle? overline,
  }) {
    return AppTypographyTokens(
      display: display ?? this.display,
      headingH1: headingH1 ?? this.headingH1,
      headingH2: headingH2 ?? this.headingH2,
      headingH3: headingH3 ?? this.headingH3,
      bodyLarge: bodyLarge ?? this.bodyLarge,
      bodyDefault: bodyDefault ?? this.bodyDefault,
      bodyDefaultEmphasis: bodyDefaultEmphasis ?? this.bodyDefaultEmphasis,
      bodySmall: bodySmall ?? this.bodySmall,
      bodySmallEmphasis: bodySmallEmphasis ?? this.bodySmallEmphasis,
      labelButton: labelButton ?? this.labelButton,
      labelTag: labelTag ?? this.labelTag,
      caption: caption ?? this.caption,
      overline: overline ?? this.overline,
    );
  }

  @override
  AppTypographyTokens lerp(
    ThemeExtension<AppTypographyTokens>? other,
    double t,
  ) {
    if (other is! AppTypographyTokens) {
      return this;
    }
    return AppTypographyTokens(
      display: TextStyle.lerp(display, other.display, t)!,
      headingH1: TextStyle.lerp(headingH1, other.headingH1, t)!,
      headingH2: TextStyle.lerp(headingH2, other.headingH2, t)!,
      headingH3: TextStyle.lerp(headingH3, other.headingH3, t)!,
      bodyLarge: TextStyle.lerp(bodyLarge, other.bodyLarge, t)!,
      bodyDefault: TextStyle.lerp(bodyDefault, other.bodyDefault, t)!,
      bodyDefaultEmphasis: TextStyle.lerp(
        bodyDefaultEmphasis,
        other.bodyDefaultEmphasis,
        t,
      )!,
      bodySmall: TextStyle.lerp(bodySmall, other.bodySmall, t)!,
      bodySmallEmphasis: TextStyle.lerp(
        bodySmallEmphasis,
        other.bodySmallEmphasis,
        t,
      )!,
      labelButton: TextStyle.lerp(labelButton, other.labelButton, t)!,
      labelTag: TextStyle.lerp(labelTag, other.labelTag, t)!,
      caption: TextStyle.lerp(caption, other.caption, t)!,
      overline: TextStyle.lerp(overline, other.overline, t)!,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppTypographyTokens &&
        other.display == display &&
        other.headingH1 == headingH1 &&
        other.headingH2 == headingH2 &&
        other.headingH3 == headingH3 &&
        other.bodyLarge == bodyLarge &&
        other.bodyDefault == bodyDefault &&
        other.bodyDefaultEmphasis == bodyDefaultEmphasis &&
        other.bodySmall == bodySmall &&
        other.bodySmallEmphasis == bodySmallEmphasis &&
        other.labelButton == labelButton &&
        other.labelTag == labelTag &&
        other.caption == caption &&
        other.overline == overline;
  }

  @override
  int get hashCode => Object.hashAll([
    display,
    headingH1,
    headingH2,
    headingH3,
    bodyLarge,
    bodyDefault,
    bodyDefaultEmphasis,
    bodySmall,
    bodySmallEmphasis,
    labelButton,
    labelTag,
    caption,
    overline,
  ]);
}

/// Extension on BuildContext for quick access to typography tokens via `context.text` or `context.typography`.
extension AppTypographyExtension on BuildContext {
  AppTypographyTokens get text => AppTypographyTokens.of(this);
  AppTypographyTokens get typography => AppTypographyTokens.of(this);
}
