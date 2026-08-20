import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/design_system/design_system.dart';

void main() {
  group('Gap Widgets', () {
    testWidgets('Gap renders SizedBox with matching width and height', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Gap(20.0),
          ),
        ),
      );

      final gapFinder = find.byType(Gap);
      expect(gapFinder, findsOneWidget);

      final gap = tester.widget<Gap>(gapFinder);
      expect(gap.size, equals(20.0));

      final sizedBoxFinder = find.descendant(
        of: gapFinder,
        matching: find.byType(SizedBox),
      );
      expect(sizedBoxFinder, findsOneWidget);

      final sizedBox = tester.widget<SizedBox>(sizedBoxFinder);
      expect(sizedBox.width, equals(20.0));
      expect(sizedBox.height, equals(20.0));
    });

    testWidgets('Semantic GapX widgets render correct token dimensions (up to Gap64)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Gap2(),
                  Gap4(),
                  Gap8(),
                  Gap12(),
                  Gap16(),
                  Gap24(),
                  Gap32(),
                  Gap40(),
                  Gap48(),
                  Gap64(),
                ],
              ),
            ),
          ),
        ),
      );

      expect(tester.widget<Gap2>(find.byType(Gap2)).size, equals(AppSpacingTokens.standard.s2));
      expect(tester.widget<Gap4>(find.byType(Gap4)).size, equals(AppSpacingTokens.standard.s4));
      expect(tester.widget<Gap8>(find.byType(Gap8)).size, equals(AppSpacingTokens.standard.s8));
      expect(tester.widget<Gap12>(find.byType(Gap12)).size, equals(AppSpacingTokens.standard.s12));
      expect(tester.widget<Gap16>(find.byType(Gap16)).size, equals(AppSpacingTokens.standard.s16));
      expect(tester.widget<Gap24>(find.byType(Gap24)).size, equals(AppSpacingTokens.standard.s24));
      expect(tester.widget<Gap32>(find.byType(Gap32)).size, equals(AppSpacingTokens.standard.s32));
      expect(tester.widget<Gap40>(find.byType(Gap40)).size, equals(AppSpacingTokens.standard.s40));
      expect(tester.widget<Gap48>(find.byType(Gap48)).size, equals(AppSpacingTokens.standard.s48));
      expect(tester.widget<Gap64>(find.byType(Gap64)).size, equals(AppSpacingTokens.standard.s64));
    });
  });
}
