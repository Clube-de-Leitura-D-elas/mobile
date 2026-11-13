import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/design_system/design_system.dart';

// Na fonte de teste cada glifo tem a largura do fontSize (16): 'Cancelar' tem
// 128 e 'Confirmar' 144. Com largura imposta o AppButton usa 16 de padding de
// cada lado, então 'Confirmar' precisa de 176 para caber numa linha.
Future<void> _pump(
  WidgetTester tester, {
  required double width,
  List<Widget>? actions,
  double textScale = 1.0,
}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
        child: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: width,
              child: AppDialogActions(
                actions:
                    actions ??
                    [
                      AppButton.secondary(label: 'Cancelar', onPressed: () {}),
                      AppButton.primary(label: 'Confirmar', onPressed: () {}),
                    ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

Rect _rectOf(WidgetTester tester, String label) {
  final origin = tester.getTopLeft(find.byType(AppDialogActions));
  return tester.getRect(find.widgetWithText(AppButton, label)).shift(-origin);
}

void main() {
  group('AppDialogActions', () {
    testWidgets(
      'quando os labels cabem, as ações ficam lado a lado com a mesma largura',
      (tester) async {
        // Fatia de (400 - 16) / 2 = 192, sobra para os 176 de 'Confirmar'.
        await _pump(tester, width: 400);

        expect(_rectOf(tester, 'Cancelar'), const Rect.fromLTWH(0, 0, 192, 40));
        expect(
          _rectOf(tester, 'Confirmar'),
          const Rect.fromLTWH(208, 0, 192, 40),
        );
        expect(
          tester.getSize(find.byType(AppDialogActions)),
          const Size(400, 40),
        );
      },
    );

    testWidgets(
      'quando um label quebraria, empilha na largura toda com a última ação em cima',
      (tester) async {
        // Fatia de (360 - 16) / 2 = 172, menor que os 176 de 'Confirmar'.
        await _pump(tester, width: 360);

        expect(
          _rectOf(tester, 'Confirmar'),
          const Rect.fromLTWH(0, 0, 360, 40),
        );
        expect(
          _rectOf(tester, 'Cancelar'),
          const Rect.fromLTWH(0, 48, 360, 40),
        );
        expect(tester.getSize(find.text('Confirmar')), const Size(144, 24));
        expect(
          tester.getSize(find.byType(AppDialogActions)),
          const Size(360, 88),
        );
      },
    );

    testWidgets(
      'em tela estreita e fonte ampliada, os labels aparecem inteiros',
      (tester) async {
        await _pump(tester, width: 320, textScale: 1.5);

        expect(tester.getSize(find.text('Cancelar')), const Size(192, 36));
        expect(tester.getSize(find.text('Confirmar')), const Size(216, 36));
        expect(_rectOf(tester, 'Confirmar').width, 320);
        expect(_rectOf(tester, 'Cancelar').width, 320);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('lado a lado, as ações ficam com a mesma altura', (
      tester,
    ) async {
      await _pump(
        tester,
        width: 400,
        actions: [
          AppButton.secondary(label: 'Sair', onPressed: () {}),
          AppButton.primary(
            label: 'Sim',
            size: AppButtonSize.lg,
            onPressed: () {},
          ),
        ],
      );

      expect(_rectOf(tester, 'Sair'), const Rect.fromLTWH(0, 0, 192, 56));
      expect(_rectOf(tester, 'Sim'), const Rect.fromLTWH(208, 0, 192, 56));
    });

    testWidgets('uma ação só ocupa a largura toda', (tester) async {
      await _pump(
        tester,
        width: 300,
        actions: [AppButton.primary(label: 'Ok', onPressed: () {})],
      );

      expect(_rectOf(tester, 'Ok'), const Rect.fromLTWH(0, 0, 300, 40));
    });

    for (final width in [400.0, 360.0]) {
      testWidgets(
        'dry layout, baseline e dimensões intrínsecas batem com o layout real (largura $width)',
        (tester) async {
          await _pump(tester, width: width);

          final box = tester.renderObject<RenderBox>(
            find.byType(AppDialogActions),
          );
          final constraints = box.constraints;
          expect(box.getDryLayout(constraints), box.size);
          expect(box.getMinIntrinsicHeight(width), box.size.height);
          expect(box.getMaxIntrinsicHeight(width), box.size.height);

          final top = tester.getTopLeft(find.byType(AppDialogActions)).dy;
          final baselines = ['Cancelar', 'Confirmar'].map((label) {
            final paragraph = tester.renderObject<RenderParagraph>(
              find.text(label),
            );
            return tester.getTopLeft(find.text(label)).dy -
                top +
                paragraph.getDryBaseline(
                  paragraph.constraints,
                  TextBaseline.alphabetic,
                )!;
          });
          expect(
            box.getDryBaseline(constraints, TextBaseline.alphabetic),
            baselines.reduce((a, b) => a < b ? a : b),
          );
        },
      );
    }

    testWidgets(
      'a largura intrínseca máxima é a da linha e a mínima a da maior ação',
      (tester) async {
        await _pump(tester, width: 400);

        final box = tester.renderObject<RenderBox>(
          find.byType(AppDialogActions),
        );
        // Sem largura imposta o AppButton usa 32 de padding de cada lado, e as
        // fatias têm a largura da maior ação.
        final maxWidth = box.getMaxIntrinsicWidth(double.infinity);
        expect(maxWidth, 2 * (144 + 64) + 16);
        expect(box.getMinIntrinsicWidth(double.infinity), 144 + 64);
        expect(box.getMinIntrinsicHeight(maxWidth), 40);
      },
    );

    testWidgets('em RTL, a primeira ação fica à direita', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 400,
                child: AppDialogActions(
                  actions: [
                    AppButton.secondary(label: 'Cancelar', onPressed: () {}),
                    AppButton.primary(label: 'Confirmar', onPressed: () {}),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      expect(_rectOf(tester, 'Cancelar'), const Rect.fromLTWH(208, 0, 192, 40));
      expect(_rectOf(tester, 'Confirmar'), const Rect.fromLTWH(0, 0, 192, 40));
    });

    testWidgets('com altura menor que o conteúdo, recorta as ações', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 360,
              height: 50,
              child: AppDialogActions(
                actions: [
                  AppButton.secondary(label: 'Cancelar', onPressed: () {}),
                  AppButton.primary(label: 'Confirmar', onPressed: () {}),
                ],
              ),
            ),
          ),
        ),
      );

      expect(
        tester.renderObject(find.byType(AppDialogActions)),
        paints..clipRect(rect: const Rect.fromLTWH(0, 0, 360, 50)),
      );
    });
  });
}
