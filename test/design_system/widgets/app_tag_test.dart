import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/design_system/design_system.dart';

void main() {
  group('AppTag', () {
    testWidgets('Renders the label text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: AppTag(label: 'Gestora')),
        ),
      );

      expect(find.text('Gestora'), findsOneWidget);
    });

    testWidgets('Defaults to the primary variant', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: AppTag(label: 'Gestora')),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;

      expect(decoration.color, AppColorTokens.light.surfaceBrandSoft);
    });

    testWidgets(
      'Primary variant uses brand-soft background and brand text color',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: const Scaffold(
              body: AppTag(label: 'Gestora', variant: TagVariant.primary),
            ),
          ),
        );

        final container = tester.widget<Container>(find.byType(Container));
        final decoration = container.decoration as BoxDecoration;
        final text = tester.widget<Text>(find.text('Gestora'));

        expect(decoration.color, AppColorTokens.light.surfaceBrandSoft);
        expect(text.style?.color, AppColorTokens.light.textBrand);
      },
    );

    testWidgets(
      'Neutral variant uses sunken background and default text color',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: const Scaffold(
              body: AppTag(label: 'Gestora', variant: TagVariant.neutral),
            ),
          ),
        );

        final container = tester.widget<Container>(find.byType(Container));
        final decoration = container.decoration as BoxDecoration;
        final text = tester.widget<Text>(find.text('Gestora'));

        expect(decoration.color, AppColorTokens.light.surfaceSunken);
        expect(text.style?.color, AppColorTokens.light.textDefault);
      },
    );

    testWidgets('Uses the labelTag typography token for the label', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: AppTag(label: 'Gestora')),
        ),
      );

      final text = tester.widget<Text>(find.text('Gestora'));

      expect(
        text.style?.fontSize,
        AppTypographyTokens.standard.labelTag.fontSize,
      );
      expect(
        text.style?.fontWeight,
        AppTypographyTokens.standard.labelTag.fontWeight,
      );
    });

    testWidgets('Renders without an icon by default', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: AppTag(label: 'Gestora')),
        ),
      );

      // Don't assert on IconTheme here: Scaffold/Material already inject
      // their own ambient IconThemes above the tree, so this only checks
      // that AppTag itself doesn't render an Icon.
      expect(find.byType(Icon), findsNothing);
    });

    testWidgets('Renders the icon before the label when provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: AppTag(label: 'Gestora', icon: Icon(Icons.star)),
          ),
        ),
      );

      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.text('Gestora'), findsOneWidget);

      final row = tester.widget<Row>(find.byType(Row));
      final iconIndex = row.children.indexWhere((w) => w is IconTheme);
      final labelIndex = row.children.indexWhere((w) => w is Text);

      expect(iconIndex, isNonNegative);
      expect(iconIndex, lessThan(labelIndex));
    });

    testWidgets('Icon uses the same color as the text for its variant', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: AppTag(
              label: 'Gestora',
              variant: TagVariant.neutral,
              icon: Icon(Icons.star),
            ),
          ),
        ),
      );

      // Look only at the IconTheme that AppTag itself renders inside its
      // Row, ignoring any ambient IconThemes injected by Scaffold/Material.
      final row = tester.widget<Row>(find.byType(Row));
      final iconTheme = row.children.whereType<IconTheme>().single;

      expect(iconTheme.data.color, AppColorTokens.light.textDefault);
    });

    testWidgets('Success variant uses success colors', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: AppTag(label: 'Presente', variant: TagVariant.success),
          ),
        ),
      );

      final tag = find.descendant(
        of: find.byType(AppTag),
        matching: find.byType(Container),
      );
      final container = tester.widget<Container>(tag.first);
      final decoration = container.decoration as BoxDecoration;
      final text = tester.widget<Text>(find.text('Presente'));

      expect(decoration.color, AppColorTokens.light.feedbackSuccessLight);
      expect(text.style?.color, AppColorTokens.light.feedbackSuccessDark);
    });

    testWidgets('Error variant uses error colors', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: AppTag(label: 'Recusado', variant: TagVariant.error),
          ),
        ),
      );

      final tag = find.descendant(
        of: find.byType(AppTag),
        matching: find.byType(Container),
      );
      final container = tester.widget<Container>(tag.first);
      final decoration = container.decoration as BoxDecoration;
      final text = tester.widget<Text>(find.text('Recusado'));

      expect(decoration.color, AppColorTokens.light.feedbackErrorLight);
      expect(text.style?.color, AppColorTokens.light.feedbackErrorDark);
    });

    testWidgets('Warning variant uses warning colors', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: AppTag(label: 'Pendente', variant: TagVariant.warning),
          ),
        ),
      );

      final tag = find.descendant(
        of: find.byType(AppTag),
        matching: find.byType(Container),
      );
      final container = tester.widget<Container>(tag.first);
      final decoration = container.decoration as BoxDecoration;
      final text = tester.widget<Text>(find.text('Pendente'));

      expect(decoration.color, AppColorTokens.light.feedbackWarningLight);
      expect(text.style?.color, AppColorTokens.light.feedbackWarningDark);
    });

    testWidgets('Uses pill shape and expected padding', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: AppTag(label: 'Gestora')),
        ),
      );

      final tag = find.descendant(
        of: find.byType(AppTag),
        matching: find.byType(Container),
      );
      final container = tester.widget<Container>(tag.first);
      final decoration = container.decoration as BoxDecoration;
      final padding = container.padding as EdgeInsets;

      expect(decoration.borderRadius, BorderRadius.circular(999));
      expect(padding.horizontal, AppSpacingTokens.standard.s16 * 2);
      expect(padding.vertical, AppSpacingTokens.standard.s4 * 2);
    });
  });
}
