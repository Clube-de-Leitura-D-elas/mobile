import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/design_system/design_system.dart';

void main() {
  group('AppCard', () {
    testWidgets('Renders the given child content', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: AppCard(child: Text('Conteúdo qualquer'))),
        ),
      );

      expect(find.text('Conteúdo qualquer'), findsOneWidget);
    });

    testWidgets('Defaults to the normal variant', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: AppCard(child: Text('Conteúdo'))),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      final border = decoration.border as Border;

      expect(decoration.color, AppColorTokens.light.surfaceDefault);
      expect(border.top.color, AppColorTokens.light.borderDefault);
      expect(border.top.width, 1);
    });

    testWidgets('Highlighted variant uses the brand border at 1.5 width', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: AppCard(
              variant: CardVariant.highlighted,
              child: Text('Conteúdo'),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      final border = decoration.border as Border;

      expect(decoration.color, AppColorTokens.light.surfaceDefault);
      expect(border.top.color, AppColorTokens.light.borderBrand);
      expect(border.top.width, 1.5);
    });

    testWidgets('Uses a 16 corner radius regardless of variant', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: AppCard(child: Text('Conteúdo'))),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      final radius = decoration.borderRadius as BorderRadius;

      expect(radius, BorderRadius.circular(16));
    });

    testWidgets('Is not tappable when onTap is not provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: AppCard(child: Text('Conteúdo'))),
        ),
      );

      expect(find.byType(InkWell), findsNothing);
    });

    testWidgets('Triggers onTap and shows a tap state when tappable', (
      tester,
    ) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: AppCard(
              onTap: () => tapped = true,
              child: const Text('Conteúdo'),
            ),
          ),
        ),
      );

      expect(find.byType(InkWell), findsOneWidget);

      await tester.tap(find.byType(InkWell));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('Toggles between normal and highlighted border on each tap', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: AppCard(onTap: () {}, child: const Text('Conteúdo')),
          ),
        ),
      );

      Border borderOf(WidgetTester t) {
        final ink = t.widget<Ink>(find.byType(Ink));
        final decoration = ink.decoration as BoxDecoration;
        return decoration.border as Border;
      }

      // Estado inicial: borda normal.
      expect(borderOf(tester).top.color, AppColorTokens.light.borderDefault);
      expect(borderOf(tester).top.width, 1);

      // Primeiro clique: alterna para o visual highlighted.
      await tester.tap(find.byType(InkWell));
      await tester.pump();

      expect(borderOf(tester).top.color, AppColorTokens.light.borderBrand);
      expect(borderOf(tester).top.width, 1.5);

      // Segundo clique: volta pro visual normal.
      await tester.tap(find.byType(InkWell));
      await tester.pump();

      expect(borderOf(tester).top.color, AppColorTokens.light.borderDefault);
      expect(borderOf(tester).top.width, 1);
    });

    testWidgets(
      'AppCard.titled renders title and support text with the right styles',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: AppCard.titled(
                title: 'Título do card',
                supportText:
                    'Texto de apoio do card, com uma linha de contexto.',
              ),
            ),
          ),
        );

        final titleText = tester.widget<Text>(find.text('Título do card'));
        final supportText = tester.widget<Text>(
          find.text('Texto de apoio do card, com uma linha de contexto.'),
        );

        expect(
          titleText.style?.fontSize,
          AppTypographyTokens.standard.bodyDefaultEmphasis.fontSize,
        );
        expect(
          titleText.style?.fontWeight,
          AppTypographyTokens.standard.bodyDefaultEmphasis.fontWeight,
        );
        expect(titleText.style?.color, AppColorTokens.light.textDefault);

        expect(
          supportText.style?.fontSize,
          AppTypographyTokens.standard.bodySmall.fontSize,
        );
        expect(supportText.style?.color, AppColorTokens.light.textMuted);
      },
    );

    testWidgets('AppCard.titled is tappable when onTap is provided', (
      tester,
    ) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: AppCard.titled(
              title: 'Título do card',
              supportText: 'Texto de apoio.',
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(InkWell));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });
}
