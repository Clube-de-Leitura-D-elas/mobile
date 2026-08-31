import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/design_system/tokens/spacing_tokens.dart';

void main() {
  group('AppSpacingTokens', () {
    test('standard tokens match exact Figma spacing specs (up to 64)', () {
      const tokens = AppSpacingTokens.standard;

      expect(tokens.s2, equals(2.0));
      expect(tokens.s4, equals(4.0));
      expect(tokens.s8, equals(8.0));
      expect(tokens.s12, equals(12.0));
      expect(tokens.s16, equals(16.0));
      expect(tokens.s24, equals(24.0));
      expect(tokens.s32, equals(32.0));
      expect(tokens.s40, equals(40.0));
      expect(tokens.s48, equals(48.0));
      expect(tokens.s64, equals(64.0));
    });

    test('supports value equality and hashCode', () {
      const tokens1 = AppSpacingTokens.standard;
      const tokens2 = AppSpacingTokens.standard;

      expect(tokens1, equals(tokens2));
      expect(tokens1.hashCode, equals(tokens2.hashCode));
    });

    test('copyWith produces updated spacing values', () {
      const tokens = AppSpacingTokens.standard;
      expect(tokens.copyWith(), equals(tokens));
      final updated = tokens.copyWith(s16: 20.0);

      expect(updated.s16, equals(20.0));
      expect(updated.s32, equals(tokens.s32));
      expect(updated, isNot(equals(tokens)));
    });

    test('lerp handles identical, null, and other instances', () {
      const tokens = AppSpacingTokens.standard;

      expect(tokens.lerp(null, 0.5), equals(tokens));
      expect(tokens.lerp(tokens, 0.0), equals(tokens));

      final modified = tokens.copyWith(s16: 32.0);
      final lerped = tokens.lerp(modified, 0.5);
      expect(lerped.s16, equals(24.0));
    });

    testWidgets('context.spacing reads AppSpacingTokens from Theme', (tester) async {
      late AppSpacingTokens retrievedTokens;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            extensions: const [AppSpacingTokens.standard],
          ),
          home: Builder(
            builder: (context) {
              retrievedTokens = context.spacing;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(retrievedTokens, equals(AppSpacingTokens.standard));
    });

    testWidgets('context.spacing falls back to AppSpacingTokens.standard if extension missing', (tester) async {
      late AppSpacingTokens retrievedTokens;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            extensions: const [],
          ),
          home: Builder(
            builder: (context) {
              retrievedTokens = context.spacing;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(retrievedTokens, equals(AppSpacingTokens.standard));
    });
  });
}
