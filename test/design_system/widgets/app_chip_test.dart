import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/design_system/design_system.dart';

Future<void> _pumpChip(WidgetTester tester, AppChip chip) {
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: Center(child: chip)),
    ),
  );
}

Material _pillMaterial(WidgetTester tester) {
  return tester.widget<Material>(
    find.descendant(of: find.byType(AppChip), matching: find.byType(Material)),
  );
}

void main() {
  group('AppChip', () {
    testWidgets('Renders the label with the labelTag typography token', (
      tester,
    ) async {
      await _pumpChip(tester, const AppChip(label: 'Já lido'));

      final text = tester.widget<Text>(find.text('Já lido'));

      expect(
        text.style?.fontSize,
        AppTypographyTokens.standard.labelTag.fontSize,
      );
      expect(
        text.style?.fontWeight,
        AppTypographyTokens.standard.labelTag.fontWeight,
      );
    });

    testWidgets('Filled variant uses brand-soft background and brand text', (
      tester,
    ) async {
      await _pumpChip(tester, const AppChip(label: 'Já lido'));

      final material = _pillMaterial(tester);
      final shape = material.shape as StadiumBorder;
      final text = tester.widget<Text>(find.text('Já lido'));

      expect(material.color, AppColorTokens.light.surfaceBrandSoft);
      expect(shape.side, BorderSide.none);
      expect(text.style?.color, AppColorTokens.light.textBrand);
    });

    testWidgets('Outlined variant uses a brand border and primary text', (
      tester,
    ) async {
      await _pumpChip(
        tester,
        const AppChip(label: 'Quero ler', variant: AppChipVariant.outlined),
      );

      final material = _pillMaterial(tester);
      final shape = material.shape as StadiumBorder;
      final text = tester.widget<Text>(find.text('Quero ler'));

      expect(material.color, Colors.transparent);
      expect(shape.side.color, AppColorTokens.light.borderBrand);
      expect(shape.side.width, 1);
      expect(text.style?.color, AppColorTokens.light.actionPrimary);
    });

    testWidgets('Uses the AppTag pill padding', (tester) async {
      await _pumpChip(tester, const AppChip(label: 'Já lido'));

      final padding = tester.widget<Padding>(
        find
            .descendant(
              of: find.byType(InkWell),
              matching: find.byType(Padding),
            )
            .first,
      );
      final insets = padding.padding as EdgeInsets;

      expect(insets.horizontal, AppSpacingTokens.standard.s16 * 2);
      expect(insets.vertical, AppSpacingTokens.standard.s4 * 2);
    });

    testWidgets('Renders the icon before the label in the variant color', (
      tester,
    ) async {
      await _pumpChip(
        tester,
        const AppChip(
          label: 'Quero ler',
          variant: AppChipVariant.outlined,
          icon: Icon(Icons.check_circle_outline),
        ),
      );

      final row = tester.widget<Row>(find.byType(Row));
      final iconTheme = row.children.whereType<IconTheme>().single;
      final iconIndex = row.children.indexOf(iconTheme);
      final labelIndex = row.children.indexWhere((w) => w is Text);

      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
      expect(iconIndex, lessThan(labelIndex));
      expect(iconTheme.data.color, AppColorTokens.light.actionPrimary);
      expect(iconTheme.data.size, 16);
    });

    testWidgets('Calls onTap when tapped', (tester) async {
      var taps = 0;
      await _pumpChip(tester, AppChip(label: 'Já lido', onTap: () => taps++));

      await tester.tap(find.byType(AppChip));

      expect(taps, 1);
    });

    testWidgets('Keeps a 48 tall tap target above the pill', (tester) async {
      var taps = 0;
      await _pumpChip(tester, AppChip(label: 'Já lido', onTap: () => taps++));

      final chipRect = tester.getRect(find.byType(AppChip));
      final pillRect = tester.getRect(find.byType(InkWell));

      expect(chipRect.height, AppChip.hitHeight);
      expect(pillRect.height, lessThan(AppChip.hitHeight));

      await tester.tapAt(Offset(chipRect.center.dx, chipRect.top + 2));

      expect(taps, 1);
    });

    testWidgets('Shows a spinner and ignores taps while loading', (
      tester,
    ) async {
      var taps = 0;
      await _pumpChip(
        tester,
        AppChip(
          label: 'Já lido',
          icon: const Icon(Icons.check_circle),
          isLoading: true,
          onTap: () => taps++,
        ),
      );

      await tester.tap(find.byType(AppChip));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsNothing);
      expect(find.text('Já lido'), findsOneWidget);
      expect(taps, 0);
    });

    testWidgets('Exposes button semantics with label and enabled state', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await _pumpChip(tester, AppChip(label: 'Já lido', onTap: () {}));

      expect(
        tester.getSemantics(find.byType(AppChip)),
        matchesSemantics(
          label: 'Já lido',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
        ),
      );
      handle.dispose();
    });

    testWidgets('Is announced as disabled while loading', (tester) async {
      final handle = tester.ensureSemantics();
      await _pumpChip(
        tester,
        AppChip(label: 'Já lido', isLoading: true, onTap: () {}),
      );

      expect(
        tester.getSemantics(find.byType(AppChip)),
        matchesSemantics(
          label: 'Já lido',
          isButton: true,
          hasEnabledState: true,
        ),
      );
      handle.dispose();
    });

    testWidgets('Is announced as disabled and ignores taps without onTap', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await _pumpChip(tester, const AppChip(label: 'Já lido'));

      await tester.tap(find.byType(AppChip), warnIfMissed: false);

      expect(
        tester.getSemantics(find.byType(AppChip)),
        matchesSemantics(
          label: 'Já lido',
          isButton: true,
          hasEnabledState: true,
        ),
      );
      expect(tester.widget<InkWell>(find.byType(InkWell)).onTap, isNull);
      handle.dispose();
    });
  });
}
