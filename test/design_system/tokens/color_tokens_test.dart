import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/design_system/tokens/color_tokens.dart';

void main() {
  group('AppColorTokens', () {
    test('light tokens have correct Figma hex values', () {
      const tokens = AppColorTokens.light;

      // Background & Surface & Border
      expect(tokens.bgDefault, equals(const Color(0xFFFFFFFF)));
      expect(tokens.bgSubtle, equals(const Color(0xFFFAF8F9)));
      expect(tokens.surfaceDefault, equals(const Color(0xFFFFFFFF)));
      expect(tokens.surfaceSunken, equals(const Color(0xFFF2EFF1)));
      expect(tokens.surfaceBrandSoft, equals(const Color(0xFFFCE8F0)));
      expect(tokens.borderDefault, equals(const Color(0xFFE4E0E3)));
      expect(tokens.borderStrong, equals(const Color(0xFFCAC4C8)));
      expect(tokens.borderBrand, equals(const Color(0xFFE74984)));

      // Text & Overlay
      expect(tokens.textDefault, equals(const Color(0xFF1B171A)));
      expect(tokens.textMuted, equals(const Color(0xFF7C7379)));
      expect(tokens.textInverse, equals(const Color(0xFFFFFFFF)));
      expect(tokens.textBrand, equals(const Color(0xFFA9144B)));
      expect(tokens.textOnBrand, equals(const Color(0xFFFFFFFF)));
      expect(tokens.overlayScrim, equals(const Color(0x801B171A)));

      // Action
      expect(tokens.actionPrimary, equals(const Color(0xFFE6256D)));
      expect(tokens.actionPrimaryHover, equals(const Color(0xFFA9144B)));
      expect(tokens.actionPrimaryPressed, equals(const Color(0xFF64102E)));
      expect(tokens.actionDanger, equals(const Color(0xFFD92D20)));
      expect(tokens.actionDisabledBg, equals(const Color(0xFFE4E0E3)));
      expect(tokens.actionDisabledFg, equals(const Color(0xFFA39BA0)));
      expect(tokens.actionFocusRing, equals(const Color(0xFFE6256D)));

      // Feedback
      expect(tokens.feedbackSuccess, equals(const Color(0xFF1E9E63)));
      expect(tokens.feedbackSuccessLight, equals(const Color(0xFFE4F6ED)));
      expect(tokens.feedbackSuccessDark, equals(const Color(0xFF14764A)));
      expect(tokens.feedbackWarning, equals(const Color(0xFFD98E04)));
      expect(tokens.feedbackWarningLight, equals(const Color(0xFFFDF3E0)));
      expect(tokens.feedbackWarningDark, equals(const Color(0xFFA66B00)));
      expect(tokens.feedbackError, equals(const Color(0xFFD92D20)));
      expect(tokens.feedbackErrorLight, equals(const Color(0xFFFCE9E7)));
      expect(tokens.feedbackErrorDark, equals(const Color(0xFFA81E14)));
      expect(tokens.feedbackInfo, equals(const Color(0xFF2563EB)));
      expect(tokens.feedbackInfoLight, equals(const Color(0xFFE6EDFD)));
      expect(tokens.feedbackInfoDark, equals(const Color(0xFF1D4ED8)));
    });

    test('dark tokens have correct Figma hex values', () {
      const tokens = AppColorTokens.dark;

      // Background & Surface & Border
      expect(tokens.bgDefault, equals(const Color(0xFF16131A)));
      expect(tokens.bgSubtle, equals(const Color(0xFF1B171A)));
      expect(tokens.surfaceDefault, equals(const Color(0xFF2A2429)));
      expect(tokens.surfaceSunken, equals(const Color(0xFF1B171A)));
      expect(tokens.surfaceBrandSoft, equals(const Color(0xFF64102E)));
      expect(tokens.borderDefault, equals(const Color(0xFF413A3E)));
      expect(tokens.borderStrong, equals(const Color(0xFF5A5257)));
      expect(tokens.borderBrand, equals(const Color(0xFFE74984)));

      // Text & Overlay
      expect(tokens.textDefault, equals(const Color(0xFFFAF8F9)));
      expect(tokens.textMuted, equals(const Color(0xFFA39BA0)));
      expect(tokens.textInverse, equals(const Color(0xFF1B171A)));
      expect(tokens.textBrand, equals(const Color(0xFFE74984)));
      expect(tokens.textOnBrand, equals(const Color(0xFFFFFFFF)));
      expect(tokens.overlayScrim, equals(const Color(0xB316131A)));

      // Action
      expect(tokens.actionPrimary, equals(const Color(0xFFE6256D)));
      expect(tokens.actionPrimaryHover, equals(const Color(0xFFE74984)));
      expect(tokens.actionPrimaryPressed, equals(const Color(0xFFA9144B)));
      expect(tokens.actionDanger, equals(const Color(0xFFD92D20)));
      expect(tokens.actionDisabledBg, equals(const Color(0xFF413A3E)));
      expect(tokens.actionDisabledFg, equals(const Color(0xFF7C7379)));
      expect(tokens.actionFocusRing, equals(const Color(0xFFE74984)));

      // Feedback
      expect(tokens.feedbackSuccess, equals(const Color(0xFF1E9E63)));
      expect(tokens.feedbackSuccessLight, equals(const Color(0xFF14764A)));
      expect(tokens.feedbackSuccessDark, equals(const Color(0xFF14764A)));
      expect(tokens.feedbackWarning, equals(const Color(0xFFD98E04)));
      expect(tokens.feedbackWarningLight, equals(const Color(0xFFA66B00)));
      expect(tokens.feedbackWarningDark, equals(const Color(0xFFA66B00)));
      expect(tokens.feedbackError, equals(const Color(0xFFD92D20)));
      expect(tokens.feedbackErrorLight, equals(const Color(0xFFA81E14)));
      expect(tokens.feedbackErrorDark, equals(const Color(0xFFA81E14)));
      expect(tokens.feedbackInfo, equals(const Color(0xFF2563EB)));
      expect(tokens.feedbackInfoLight, equals(const Color(0xFF1D4ED8)));
      expect(tokens.feedbackInfoDark, equals(const Color(0xFF1D4ED8)));
    });

    test('supports value equality and hashCode', () {
      expect(AppColorTokens.light, equals(AppColorTokens.light));
      expect(AppColorTokens.light.hashCode, equals(AppColorTokens.light.hashCode));
      expect(AppColorTokens.light, isNot(equals(AppColorTokens.dark)));
    });

    test('copyWith produces updated values', () {
      const tokens = AppColorTokens.light;
      final updated = tokens.copyWith(bgDefault: const Color(0xFF000000));

      expect(updated.bgDefault, equals(const Color(0xFF000000)));
      expect(updated.bgSubtle, equals(tokens.bgSubtle));
      expect(updated, isNot(equals(tokens)));
    });

    test('lerp handles identical, null, and non-token instances', () {
      const light = AppColorTokens.light;
      const dark = AppColorTokens.dark;

      expect(light.lerp(null, 0.5), equals(light));
      expect(light.lerp(light, 0.0), equals(light));

      final lerpedHalf = light.lerp(dark, 0.5);
      expect(
        lerpedHalf.actionPrimary,
        equals(Color.lerp(light.actionPrimary, dark.actionPrimary, 0.5)),
      );
    });

    testWidgets('context.colors reads AppColorTokens from Theme', (tester) async {
      late AppColorTokens retrievedTokens;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            extensions: const [AppColorTokens.light],
          ),
          home: Builder(
            builder: (context) {
              retrievedTokens = context.colors;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(retrievedTokens, equals(AppColorTokens.light));
    });

    testWidgets('context.colors falls back correctly based on brightness when extension missing', (tester) async {
      late AppColorTokens retrievedTokens;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: Brightness.dark),
          home: Builder(
            builder: (context) {
              retrievedTokens = context.colors;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(retrievedTokens, equals(AppColorTokens.dark));
    });
  });
}
