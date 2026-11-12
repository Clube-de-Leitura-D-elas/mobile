import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
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

      expect(tester.getSize(find.widgetWithText(AppButton, 'Sm')).height, 32.0);
      expect(tester.getSize(find.widgetWithText(AppButton, 'Md')).height, 40.0);
      expect(tester.getSize(find.widgetWithText(AppButton, 'Lg')).height, 56.0);
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

    testWidgets('Centers the label without stretching or clipping it', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Column(
              children: [
                for (final size in AppButtonSize.values) ...[
                  AppButton.primary(size: size, label: 'Primary $size', onPressed: () {}),
                  AppButton.secondary(size: size, label: 'Secondary $size', onPressed: () {}),
                ],
              ],
            ),
          ),
        ),
      );

      for (final size in AppButtonSize.values) {
        for (final label in ['Primary $size', 'Secondary $size']) {
          // A caixa do Text deve ter exatamente a altura do texto: maior indica
          // label esticado e desenhado no topo; menor indica label cortado.
          final paragraph = tester.renderObject<RenderParagraph>(find.text(label));
          expect(paragraph.size.height, paragraph.textSize.height, reason: label);

          final text = tester.getRect(find.text(label));
          final button = tester.getRect(
            find.ancestor(of: find.text(label), matching: find.byType(InkWell)),
          );
          expect(text.center.dy, moreOrLessEquals(button.center.dy, epsilon: 0.5), reason: label);
        }
      }
    });

    // Na fonte de teste (FlutterTest) cada glifo tem a largura do fontSize:
    // no labelButton (16px), 'Sair' mede 64 e 'Sim' 48.
    group('label sem corte', () {
      testWidgets('com largura imposta, o label cabe numa linha e o botão mantém 40 de altura', (tester) async {
        // Cada botão fica com 100 de largura: o label cabe com padding de 16,
        // mas quebraria com o 32 do md.
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 216,
                  child: Row(
                    children: [
                      Expanded(child: AppButton.secondary(label: 'Sair', onPressed: () {})),
                      const Gap16(),
                      Expanded(child: AppButton.primary(label: 'Sim', onPressed: () {})),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        expect(tester.getSize(find.text('Sair')), const Size(64, 24));
        expect(tester.getSize(find.text('Sim')), const Size(48, 24));
        expect(tester.getSize(find.widgetWithText(AppButton, 'Sair')).height, 40.0);
        expect(tester.getSize(find.widgetWithText(AppButton, 'Sim')).height, 40.0);
      });

      testWidgets('com fonte ampliada, o botão cresce em vez de cortar ou encolher o label', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(2)),
              child: Scaffold(
                body: Center(
                  child: SizedBox(
                    width: 400,
                    child: AppButton.primary(label: 'Sair', onPressed: () {}),
                  ),
                ),
              ),
            ),
          ),
        );

        expect(tester.getSize(find.text('Sair')), const Size(128, 48));
        expect(tester.getSize(find.byType(AppButton)).height, 64.0);
      });

      testWidgets('sem largura imposta, o botão mantém o padding de 32 do md', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: Row(children: [AppButton.primary(label: 'Sair', onPressed: () {})]),
            ),
          ),
        );

        expect(tester.getSize(find.byType(AppButton)).width, 64.0 + 2 * 32);
      });

      testWidgets('responde às dimensões intrínsecas (IntrinsicWidth/IntrinsicHeight)', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: Column(
                children: [
                  IntrinsicWidth(child: AppButton.primary(label: 'Sair', onPressed: () {})),
                  IntrinsicHeight(
                    child: Row(children: [AppButton.secondary(label: 'Sim', onPressed: () {})]),
                  ),
                ],
              ),
            ),
          ),
        );

        expect(tester.takeException(), isNull);
        expect(tester.getSize(find.widgetWithText(AppButton, 'Sair')), const Size(64.0 + 2 * 32, 40));
        expect(tester.getSize(find.widgetWithText(AppButton, 'Sim')).height, 40.0);
      });

      testWidgets('a altura intrínseca não fica menor que a do layout com largura frouxa', (tester) async {
        // Com 200 de largura, o label cabe numa linha com padding de 16 (168),
        // mas quebra em duas com o 32 que a Column (largura frouxa) usa.
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 200,
                  child: IntrinsicHeight(
                    child: Column(
                      children: [AppButton.primary(label: 'Confirmar', onPressed: () {})],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        expect(tester.takeException(), isNull);
        expect(tester.getSize(find.byType(AppButton)).height, 64.0);
        expect(tester.getSize(find.byType(IntrinsicHeight)).height, 64.0);
      });

      testWidgets('com largura imposta folgada, o botão fica igual ao de antes', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 400,
                  child: Row(children: [Expanded(child: AppButton.primary(label: 'Sair', onPressed: () {}))]),
                ),
              ),
            ),
          ),
        );

        expect(tester.getSize(find.byType(AppButton)), const Size(400, 40));
        expect(tester.getCenter(find.text('Sair')), tester.getCenter(find.byType(AppButton)));
      });

      testWidgets('com largura imposta e fonte ampliada, o label fica numa linha e o botão cresce', (tester) async {
        // 'Sair' em 1,5x mede 96 x 36: cabe nos 108 que sobram com padding de
        // 16 num botão de 140, mas não nos 76 do padding de 32.
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
              child: Scaffold(
                body: Center(
                  child: SizedBox(
                    width: 140,
                    child: Row(children: [Expanded(child: AppButton.primary(label: 'Sair', onPressed: () {}))]),
                  ),
                ),
              ),
            ),
          ),
        );

        expect(tester.getSize(find.text('Sair')), const Size(96, 36));
        expect(tester.getSize(find.byType(AppButton)), const Size(140, 52));
      });

      // 'Confirmar' (144) quebra em mais linhas com o padding de 32 do que com
      // o de 16 num botão de 100: a altura denuncia qual padding foi usado.
      for (final tight in [true, false]) {
        testWidgets('dry layout, baseline e altura intrínseca batem com o layout real (largura ${tight ? 'imposta' : 'frouxa'})', (tester) async {
          final button = AppButton.primary(label: 'Confirmar', onPressed: () {});
          await tester.pumpWidget(
            MaterialApp(
              theme: AppTheme.light,
              home: Scaffold(
                body: Align(
                  alignment: Alignment.topLeft,
                  child: tight
                      ? SizedBox(width: 100, child: button)
                      : ConstrainedBox(constraints: const BoxConstraints(maxWidth: 100), child: button),
                ),
              ),
            ),
          );

          final box = tester.renderObject<RenderBox>(find.byType(AppButton));
          final constraints = box.constraints;

          expect(box.getDryLayout(constraints), box.size);
          final paragraph = tester.renderObject<RenderParagraph>(find.text('Confirmar'));
          final labelTop = tester.getTopLeft(find.text('Confirmar')).dy - tester.getTopLeft(find.byType(AppButton)).dy;
          expect(
            box.getDryBaseline(constraints, TextBaseline.alphabetic),
            labelTop + paragraph.getDryBaseline(paragraph.constraints, TextBaseline.alphabetic)!,
          );
          expect(box.getMinIntrinsicHeight(100), greaterThanOrEqualTo(box.size.height));
          expect(box.getMaxIntrinsicHeight(100), greaterThanOrEqualTo(box.size.height));
        });
      }
    });
  });
}
