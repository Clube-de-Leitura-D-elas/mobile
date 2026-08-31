import 'package:flutter/material.dart';
import '../tokens/color_tokens.dart';
import '../tokens/spacing_tokens.dart';
import '../tokens/typography_tokens.dart';

/// Provides [ThemeData] configurations for Light and Dark modes
/// using [AppColorTokens], [AppTypographyTokens], and [AppSpacingTokens].
abstract final class AppTheme {
  /// Light theme for the application.
  static final ThemeData light = _buildTheme(
    brightness: Brightness.light,
    colorTokens: AppColorTokens.light,
    typographyTokens: AppTypographyTokens.standard,
    spacingTokens: AppSpacingTokens.standard,
  );

  /// Dark theme for the application.
  static final ThemeData dark = _buildTheme(
    brightness: Brightness.dark,
    colorTokens: AppColorTokens.dark,
    typographyTokens: AppTypographyTokens.standard,
    spacingTokens: AppSpacingTokens.standard,
  );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required AppColorTokens colorTokens,
    required AppTypographyTokens typographyTokens,
    required AppSpacingTokens spacingTokens,
  }) {
    final isDark = brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: colorTokens.bgDefault,
      colorScheme: isDark
          ? ColorScheme.dark(
              primary: colorTokens.actionPrimary,
              onPrimary: colorTokens.textOnBrand,
              surface: colorTokens.surfaceDefault,
              onSurface: colorTokens.textDefault,
              error: colorTokens.feedbackError,
              onError: colorTokens.textOnBrand,
              outline: colorTokens.borderDefault,
            )
          : ColorScheme.light(
              primary: colorTokens.actionPrimary,
              onPrimary: colorTokens.textOnBrand,
              surface: colorTokens.surfaceDefault,
              onSurface: colorTokens.textDefault,
              error: colorTokens.feedbackError,
              onError: colorTokens.textOnBrand,
              outline: colorTokens.borderDefault,
            ),
      textTheme: TextTheme(
        displayLarge: typographyTokens.display,
        headlineLarge: typographyTokens.headingH1,
        headlineMedium: typographyTokens.headingH2,
        headlineSmall: typographyTokens.headingH3,
        titleLarge: typographyTokens.bodyLarge,
        bodyLarge: typographyTokens.bodyLarge,
        bodyMedium: typographyTokens.bodyDefault,
        bodySmall: typographyTokens.bodySmall,
        labelLarge: typographyTokens.labelButton,
        labelMedium: typographyTokens.bodyDefaultEmphasis,
        labelSmall: typographyTokens.labelTag,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colorTokens.bgDefault,
        foregroundColor: colorTokens.textDefault,
        elevation: 0,
      ),
      dividerColor: colorTokens.borderDefault,
      disabledColor: colorTokens.actionDisabledFg,
      extensions: [colorTokens, typographyTokens, spacingTokens],
    );
  }
}
