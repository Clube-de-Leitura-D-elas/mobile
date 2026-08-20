import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/design_system/design_system.dart';

void main() {
  group('AppTheme', () {
    test('AppTheme.light configures light brightness, color tokens, and textTheme', () {
      final theme = AppTheme.light;
      final colorTokens = AppColorTokens.light;
      final typographyTokens = AppTypographyTokens.standard;

      expect(theme.brightness, equals(Brightness.light));
      expect(theme.scaffoldBackgroundColor, equals(colorTokens.bgDefault));
      expect(theme.colorScheme.primary, equals(colorTokens.actionPrimary));
      expect(theme.colorScheme.onPrimary, equals(colorTokens.textOnBrand));
      expect(theme.colorScheme.surface, equals(colorTokens.surfaceDefault));
      expect(theme.colorScheme.onSurface, equals(colorTokens.textDefault));
      expect(theme.colorScheme.error, equals(colorTokens.feedbackError));
      expect(theme.colorScheme.outline, equals(colorTokens.borderDefault));
      expect(theme.appBarTheme.backgroundColor, equals(colorTokens.bgDefault));
      expect(theme.dividerColor, equals(colorTokens.borderDefault));
      expect(theme.disabledColor, equals(colorTokens.actionDisabledFg));

      expect(theme.textTheme.displayLarge?.fontSize, equals(typographyTokens.display.fontSize));
      expect(theme.textTheme.displayLarge?.height, equals(typographyTokens.display.height));
      expect(theme.textTheme.headlineLarge?.fontSize, equals(typographyTokens.headingH1.fontSize));
      expect(theme.textTheme.bodyMedium?.fontSize, equals(typographyTokens.bodyDefault.fontSize));
      expect(theme.textTheme.labelLarge?.fontSize, equals(typographyTokens.labelButton.fontSize));

      final extensionColorTokens = theme.extension<AppColorTokens>();
      expect(extensionColorTokens, equals(colorTokens));

      final extensionTypographyTokens = theme.extension<AppTypographyTokens>();
      expect(extensionTypographyTokens, equals(typographyTokens));
    });

    test('AppTheme.dark configures dark brightness, color tokens, and textTheme', () {
      final theme = AppTheme.dark;
      final colorTokens = AppColorTokens.dark;
      final typographyTokens = AppTypographyTokens.standard;

      expect(theme.brightness, equals(Brightness.dark));
      expect(theme.scaffoldBackgroundColor, equals(colorTokens.bgDefault));
      expect(theme.colorScheme.primary, equals(colorTokens.actionPrimary));
      expect(theme.colorScheme.onPrimary, equals(colorTokens.textOnBrand));
      expect(theme.colorScheme.surface, equals(colorTokens.surfaceDefault));
      expect(theme.colorScheme.onSurface, equals(colorTokens.textDefault));
      expect(theme.colorScheme.error, equals(colorTokens.feedbackError));
      expect(theme.colorScheme.outline, equals(colorTokens.borderDefault));
      expect(theme.appBarTheme.backgroundColor, equals(colorTokens.bgDefault));
      expect(theme.dividerColor, equals(colorTokens.borderDefault));
      expect(theme.disabledColor, equals(colorTokens.actionDisabledFg));

      expect(theme.textTheme.displayLarge?.fontSize, equals(typographyTokens.display.fontSize));
      expect(theme.textTheme.headlineLarge?.fontSize, equals(typographyTokens.headingH1.fontSize));

      final extensionColorTokens = theme.extension<AppColorTokens>();
      expect(extensionColorTokens, equals(colorTokens));

      final extensionTypographyTokens = theme.extension<AppTypographyTokens>();
      expect(extensionTypographyTokens, equals(typographyTokens));
    });

    test('AppTheme returns identical cached instances on repeated access', () {
      expect(identical(AppTheme.light, AppTheme.light), isTrue);
      expect(identical(AppTheme.dark, AppTheme.dark), isTrue);
    });
  });
}
