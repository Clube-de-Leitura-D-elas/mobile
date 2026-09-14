import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/design_system/design_system.dart';

void main() {
  group('AppButton', () {
    testWidgets('Primary button renders label and triggers onPressed callback via InkWell', (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: AppButton(
              label: 'Confirmar',
              onPressed: () {
                pressed = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Confirmar'), findsOneWidget);
      expect(find.byType(InkWell), findsOneWidget);

      await tester.tap(find.byType(InkWell));
      expect(pressed, isTrue);
    });

    testWidgets('Disabled button does not trigger onPressed callback', (tester) async {
      const pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: AppButton.primary(
              label: 'Disabled',
              onPressed: null,
            ),
          ),
        ),
      );

      final inkWell = tester.widget<InkWell>(find.byType(InkWell));
      expect(inkWell.onTap, isNull);

      await tester.tap(find.byType(InkWell));
      expect(pressed, isFalse);
    });

    testWidgets('Renders correct heights for Sm (32), Md (40), and Lg (56) sizes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: Column(
              children: [
                AppButton.primary(size: AppButtonSize.sm, label: 'Sm', onPressed: null),
                AppButton.primary(size: AppButtonSize.md, label: 'Md', onPressed: null),
                AppButton.primary(size: AppButtonSize.lg, label: 'Lg', onPressed: null),
              ],
            ),
          ),
        ),
      );

      final containers = tester.widgetList<Container>(
        find.ancestor(of: find.byType(Material), matching: find.byType(Container)),
      );

      final heights = containers.map((c) => c.constraints?.maxHeight ?? 0.0).toList();
      expect(heights.contains(32.0), isTrue);
      expect(heights.contains(40.0), isTrue);
      expect(heights.contains(56.0), isTrue);
    });

    testWidgets('Renders all variants (Primary, Secondary, Ghost, Danger) without error', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Column(
              children: [
                AppButton.primary(label: 'Primary', onPressed: () {}),
                AppButton.secondary(label: 'Secondary', onPressed: () {}),
                AppButton.ghost(label: 'Ghost', onPressed: () {}),
                AppButton.danger(label: 'Danger', onPressed: () {}),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Primary'), findsOneWidget);
      expect(find.text('Secondary'), findsOneWidget);
      expect(find.text('Ghost'), findsOneWidget);
      expect(find.text('Danger'), findsOneWidget);
    });

    testWidgets('Renders leading and trailing icons correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Column(
              children: [
                AppButton.primary(
                  label: 'Leading Icon',
                  icon: const Icon(Icons.add),
                  onPressed: () {},
                ),
                AppButton.primary(
                  label: 'Trailing Icon',
                  icon: const Icon(Icons.arrow_forward),
                  iconAlignment: IconAlignment.end,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
      expect(find.text('Leading Icon'), findsOneWidget);
      expect(find.text('Trailing Icon'), findsOneWidget);
    });

    testWidgets('Renders loading indicator when isLoading is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: AppButton.primary(
            label: 'Loading',
            isLoading: true,
            onPressed: () {},
          ),
        ),
      );

      final indicator = find.byType(CircularProgressIndicator);
      expect(indicator, findsOneWidget);
      expect(tester.getSize(indicator), const Size(16.0, 16.0));
    });
  });
}
