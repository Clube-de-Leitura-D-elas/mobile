import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/design_system/design_system.dart';

void main() {
  group('AppStarRating - Display Mode', () {
    testWidgets('renders 5 stars with correct full, half, and empty icons for 4.5', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: AppStarRating.display(rating: 4.5),
          ),
        ),
      );

      expect(find.byType(AppStarRating), findsOneWidget);
      expect(find.byIcon(Icons.star_rounded), findsNWidgets(5));
      expect(find.byIcon(Icons.star_outline_rounded), findsOneWidget);
      expect(find.bySemanticsLabel('4,5 de 5 estrelas'), findsOneWidget);
    });

    testWidgets('renders correct icons for integer rating 3.0', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: AppStarRating.display(rating: 3.0),
          ),
        ),
      );

      expect(find.byIcon(Icons.star_rounded), findsNWidgets(3));
      expect(find.byIcon(Icons.star_outline_rounded), findsNWidgets(2));
      expect(find.bySemanticsLabel('3 de 5 estrelas'), findsOneWidget);
    });

    testWidgets('renders 5 empty stars for 0 rating', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: AppStarRating.display(rating: 0),
          ),
        ),
      );

      expect(find.byIcon(Icons.star_rounded), findsNothing);
      expect(find.byIcon(Icons.star_outline_rounded), findsNWidgets(5));
      expect(find.bySemanticsLabel('0 de 5 estrelas'), findsOneWidget);
    });

    testWidgets('respects sm and md sizes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: Column(
              children: [
                AppStarRating.display(rating: 5, size: AppStarRatingSize.sm),
                AppStarRating.display(rating: 5, size: AppStarRatingSize.md),
              ],
            ),
          ),
        ),
      );

      final smIcon = tester.widget<Icon>(find.byIcon(Icons.star_rounded).first);
      expect(smIcon.size, AppStarRatingSize.sm.starSize);

      final mdIcon = tester.widget<Icon>(find.byIcon(Icons.star_rounded).at(5));
      expect(mdIcon.size, AppStarRatingSize.md.starSize);
    });

    testWidgets('uses custom semanticLabel when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: AppStarRating.display(
              rating: 4.5,
              semanticLabel: 'Nota personalizada',
            ),
          ),
        ),
      );

      expect(find.bySemanticsLabel('Nota personalizada'), findsOneWidget);
    });
  });

  group('AppStarRating - Input Mode', () {
    testWidgets('renders 5 star buttons and selects rating on tap', (
      tester,
    ) async {
      int? selected;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return AppStarRating.input(
                  rating: selected ?? 0,
                  onChanged: (val) {
                    setState(() {
                      selected = val;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.star_outline_rounded), findsNWidgets(5));
      expect(find.byIcon(Icons.star_rounded), findsNothing);

      await tester.tap(find.bySemanticsLabel('4 de 5 estrelas'));
      await tester.pump();

      expect(selected, 4);
      expect(find.byIcon(Icons.star_rounded), findsNWidgets(4));
      expect(find.byIcon(Icons.star_outline_rounded), findsOneWidget);
    });

    testWidgets('disabled input mode does not trigger onChanged', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: AppStarRating.input(
              rating: 2,
              onChanged: null,
            ),
          ),
        ),
      );

      final inkWells = tester.widgetList<InkWell>(find.byType(InkWell));
      for (final inkWell in inkWells) {
        expect(inkWell.onTap, isNull);
      }
    });

    testWidgets('exposes individual semantic buttons', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: AppStarRating.input(
              rating: 3,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      for (var i = 1; i <= 5; i++) {
        expect(find.bySemanticsLabel('$i de 5 estrelas'), findsOneWidget);
      }
    });

    Future<void> pumpInputWithWidth(WidgetTester tester, double width) {
      return tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: width,
                child: Center(
                  child: AppStarRating.input(rating: 3, onChanged: (_) {}),
                ),
              ),
            ),
          ),
        ),
      );
    }

    double rowWidth(WidgetTester tester) =>
        tester.getSize(find.byType(Wrap)).width;

    void expectSingleRow(WidgetTester tester) {
      final targets = find.byType(InkWell);
      expect(targets, findsNWidgets(5));
      final top = tester.getTopLeft(targets.first).dy;
      for (final target in targets.evaluate()) {
        expect(tester.getTopLeft(find.byWidget(target.widget)).dy, top);
      }
    }

    testWidgets('keeps 48dp tap targets and the gap when there is room', (
      tester,
    ) async {
      await pumpInputWithWidth(tester, 400);

      expect(tester.takeException(), isNull);
      expect(rowWidth(tester), 5 * 48 + 4 * 8);
      expect(tester.getSize(find.byType(InkWell).first), const Size(48, 48));
    });

    testWidgets('shrinks the gap to fit a narrow dialog without overflow', (
      tester,
    ) async {
      await pumpInputWithWidth(tester, 250);

      expect(tester.takeException(), isNull);
      expect(rowWidth(tester), lessThanOrEqualTo(250));
      expect(tester.getSize(find.byType(InkWell).first), const Size(48, 48));
      expectSingleRow(tester);
    });

    testWidgets('keeps one row with no gap when 5 x 48dp fit exactly', (
      tester,
    ) async {
      await pumpInputWithWidth(tester, 240);

      expect(tester.takeException(), isNull);
      expect(rowWidth(tester), 240);
      expectSingleRow(tester);
    });

    testWidgets('wraps the stars instead of shrinking the 48dp targets', (
      tester,
    ) async {
      await pumpInputWithWidth(tester, 200);

      expect(tester.takeException(), isNull);
      expect(rowWidth(tester), lessThanOrEqualTo(200));
      final targets = find.byType(InkWell);
      expect(targets, findsNWidgets(5));
      for (final target in targets.evaluate()) {
        expect(tester.getSize(find.byWidget(target.widget)), const Size(48, 48));
      }
      expect(
        tester.getTopLeft(targets.last).dy,
        greaterThan(tester.getTopLeft(targets.first).dy),
      );
    });
  });
}
