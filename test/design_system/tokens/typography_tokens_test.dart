import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/design_system/tokens/typography_tokens.dart';

void main() {
  group('AppTypographyTokens', () {
    test('standard tokens match exact Figma typography specs', () {
      const tokens = AppTypographyTokens.standard;

      // Display & Headings
      expect(tokens.display.fontSize, equals(40.0));
      expect(tokens.display.height, equals(48.0 / 40.0));
      expect(tokens.display.fontWeight, equals(FontWeight.w700));

      expect(tokens.headingH1.fontSize, equals(32.0));
      expect(tokens.headingH1.height, equals(40.0 / 32.0));
      expect(tokens.headingH1.fontWeight, equals(FontWeight.w700));

      expect(tokens.headingH2.fontSize, equals(24.0));
      expect(tokens.headingH2.height, equals(32.0 / 24.0));
      expect(tokens.headingH2.fontWeight, equals(FontWeight.w700));

      expect(tokens.headingH3.fontSize, equals(20.0));
      expect(tokens.headingH3.height, equals(28.0 / 20.0));
      expect(tokens.headingH3.fontWeight, equals(FontWeight.w700));

      // Body
      expect(tokens.bodyLarge.fontSize, equals(18.0));
      expect(tokens.bodyLarge.height, equals(28.0 / 18.0));
      expect(tokens.bodyLarge.fontWeight, equals(FontWeight.w400));

      expect(tokens.bodyDefault.fontSize, equals(16.0));
      expect(tokens.bodyDefault.height, equals(24.0 / 16.0));
      expect(tokens.bodyDefault.fontWeight, equals(FontWeight.w400));

      expect(tokens.bodyDefaultEmphasis.fontSize, equals(16.0));
      expect(tokens.bodyDefaultEmphasis.height, equals(24.0 / 16.0));
      expect(tokens.bodyDefaultEmphasis.fontWeight, equals(FontWeight.w600));

      expect(tokens.bodySmall.fontSize, equals(14.0));
      expect(tokens.bodySmall.height, equals(20.0 / 14.0));
      expect(tokens.bodySmall.fontWeight, equals(FontWeight.w400));

      expect(tokens.bodySmallEmphasis.fontSize, equals(14.0));
      expect(tokens.bodySmallEmphasis.height, equals(20.0 / 14.0));
      expect(tokens.bodySmallEmphasis.fontWeight, equals(FontWeight.w600));

      // Labels, Caption & Overline
      expect(tokens.labelButton.fontSize, equals(16.0));
      expect(tokens.labelButton.height, equals(24.0 / 16.0));
      expect(tokens.labelButton.fontWeight, equals(FontWeight.w700));

      expect(tokens.labelTag.fontSize, equals(12.0));
      expect(tokens.labelTag.height, equals(16.0 / 12.0));
      expect(tokens.labelTag.fontWeight, equals(FontWeight.w700));

      expect(tokens.caption.fontSize, equals(12.0));
      expect(tokens.caption.height, equals(16.0 / 12.0));
      expect(tokens.caption.fontWeight, equals(FontWeight.w400));

      expect(tokens.overline.fontSize, equals(12.0));
      expect(tokens.overline.height, equals(16.0 / 12.0));
      expect(tokens.overline.fontWeight, equals(FontWeight.w700));
      expect(tokens.overline.letterSpacing, equals(0.96));
    });

    test('supports value equality and hashCode', () {
      const tokens1 = AppTypographyTokens.standard;
      const tokens2 = AppTypographyTokens.standard;

      expect(tokens1, equals(tokens2));
      expect(tokens1.hashCode, equals(tokens2.hashCode));
    });

    test('copyWith produces updated typography values', () {
      const tokens = AppTypographyTokens.standard;
      expect(tokens.copyWith(), equals(tokens));
      const customStyle = TextStyle(fontSize: 50.0);
      final updated = tokens.copyWith(display: customStyle);

      expect(updated.display, equals(customStyle));
      expect(updated.headingH1, equals(tokens.headingH1));
      expect(updated, isNot(equals(tokens)));
    });

    test('lerp handles identical, null, and other instances', () {
      const tokens = AppTypographyTokens.standard;

      expect(tokens.lerp(null, 0.5), equals(tokens));
      expect(tokens.lerp(tokens, 0.0), equals(tokens));

      final modified = tokens.copyWith(
        display: const TextStyle(fontSize: 50.0),
      );
      final lerped = tokens.lerp(modified, 0.5);
      expect(lerped.display.fontSize, equals(45.0));
    });

    testWidgets(
      'context.text and context.typography read AppTypographyTokens from Theme',
      (tester) async {
        late AppTypographyTokens textTokens;
        late AppTypographyTokens typographyTokens;

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(extensions: const [AppTypographyTokens.standard]),
            home: Builder(
              builder: (context) {
                textTokens = context.text;
                typographyTokens = context.typography;
                return const SizedBox();
              },
            ),
          ),
        );

        expect(textTokens, equals(AppTypographyTokens.standard));
        expect(typographyTokens, equals(AppTypographyTokens.standard));
      },
    );

    testWidgets(
      'context.text falls back to AppTypographyTokens.standard if extension is missing',
      (tester) async {
        late AppTypographyTokens retrievedTokens;

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(extensions: const []),
            home: Builder(
              builder: (context) {
                retrievedTokens = context.text;
                return const SizedBox();
              },
            ),
          ),
        );

        expect(retrievedTokens, equals(AppTypographyTokens.standard));
      },
    );
  });
}
