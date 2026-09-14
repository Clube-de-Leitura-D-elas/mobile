import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/design_system/design_system.dart';

void main() {
  group('AppCheckbox', () {
    testWidgets('unchecked box is empty and uses the strong border token', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: AppCheckbox(value: false, onChanged: _noop),
          ),
        ),
      );

      expect(find.byIcon(Icons.check), findsNothing);
      expect(_faceColor(tester), AppColorTokens.light.surfaceDefault);
      expect(_faceBorderColor(tester), AppColorTokens.light.borderStrong);
    });

    testWidgets('checked box uses the primary action token and a mark', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: AppCheckbox(value: true, onChanged: _noop),
          ),
        ),
      );

      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(_faceColor(tester), AppColorTokens.light.actionPrimary);
      expect(_faceBorderColor(tester), AppColorTokens.light.actionPrimary);
    });

    testWidgets('disabled box does not toggle and uses disabled tokens', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: AppCheckbox(value: false, onChanged: null),
          ),
        ),
      );

      final inkWell = tester.widget<InkWell>(find.byType(InkWell));
      expect(inkWell.onTap, isNull);
      expect(_faceBorderColor(tester), AppColorTokens.light.actionDisabledFg);

      await tester.tap(find.byType(AppCheckbox));
      await tester.pump();
      expect(find.byIcon(Icons.check), findsNothing);
    });

    testWidgets('tap reports the toggled value', (tester) async {
      bool? next;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: AppCheckbox(value: false, onChanged: (value) => next = value),
          ),
        ),
      );

      await tester.tap(find.byType(AppCheckbox));
      expect(next, isTrue);
    });

    testWidgets('tapping the label toggles the box', (tester) async {
      bool? next;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: AppCheckbox(
              value: false,
              label: 'Presente',
              onChanged: (value) => next = value,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Presente'));
      expect(next, isTrue);
    });

    testWidgets('hit target is larger than the painted box', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: AppCheckbox(value: false, onChanged: _noop),
          ),
        ),
      );

      final hit = tester.getSize(find.byType(InkWell));
      final visual = tester.getSize(
        find.byWidgetPredicate(
          (widget) =>
              widget is SizedBox &&
              widget.width == AppCheckbox.visualSize &&
              widget.height == AppCheckbox.visualSize,
        ),
      );

      expect(visual.width, AppCheckbox.visualSize);
      expect(hit.width, greaterThanOrEqualTo(AppCheckbox.hitSize));
      expect(hit.height, greaterThanOrEqualTo(AppCheckbox.hitSize));
      expect(hit.width, greaterThan(visual.width));
      expect(hit.height, greaterThan(visual.height));
    });

    testWidgets('dark theme uses dark tokens when checked', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: const Scaffold(
            body: AppCheckbox(value: true, onChanged: _noop),
          ),
        ),
      );

      expect(_faceColor(tester), AppColorTokens.dark.actionPrimary);
      expect(_faceBorderColor(tester), AppColorTokens.dark.actionPrimary);
    });

    testWidgets('dark theme uses dark tokens when unchecked', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: const Scaffold(
            body: AppCheckbox(value: false, onChanged: _noop),
          ),
        ),
      );

      expect(_faceColor(tester), AppColorTokens.dark.surfaceDefault);
      expect(_faceBorderColor(tester), AppColorTokens.dark.borderStrong);
    });
  });
}

void _noop(bool value) {}

Color? _faceColor(WidgetTester tester) => _face(tester).color;

Color? _faceBorderColor(WidgetTester tester) => _face(tester).border?.top.color;

BoxDecoration _face(WidgetTester tester) {
  final boxes = tester.widgetList<DecoratedBox>(find.byType(DecoratedBox));
  return boxes
      .map((box) => box.decoration)
      .whereType<BoxDecoration>()
      .firstWhere(
        (decoration) => decoration.borderRadius == BorderRadius.circular(8),
      );
}
