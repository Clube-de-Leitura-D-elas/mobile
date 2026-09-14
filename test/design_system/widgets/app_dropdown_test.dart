import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/design_system/widgets/app_dropdown.dart';

void main() {
  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(body: Center(child: child)),
    );
  }

  group('AppDropdown Unit & Widget Tests', () {
    const options = ['Opção A', 'Opção B', 'Opção C'];

    testWidgets('Renderiza label e hintText corretamente quando valor é nulo', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          AppDropdown<String>(
            label: 'Selecione a Categoria',
            hintText: 'Escolha uma opção',
            value: null,
            items: options,
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.text('Selecione a Categoria'), findsOneWidget);
      expect(find.text('Escolha uma opção'), findsOneWidget);
    });

    testWidgets(
      'Abre o overlay ao tocar no gatilho e fecha ao selecionar um item',
      (tester) async {
        String? selectedValue;

        await tester.pumpWidget(
          buildTestableWidget(
            StatefulBuilder(
              builder: (context, setState) {
                return AppDropdown<String>(
                  hintText: 'Escolha',
                  value: selectedValue,
                  items: options,
                  onChanged: (val) => setState(() => selectedValue = val),
                );
              },
            ),
          ),
        );

        await tester.tap(find.text('Escolha'));
        await tester.pumpAndSettle();

        expect(find.text('Opção A'), findsOneWidget);
        expect(find.text('Opção B'), findsOneWidget);

        await tester.tap(find.text('Opção B'));
        await tester.pumpAndSettle();

        expect(find.text('Opção B'), findsOneWidget);
        expect(selectedValue, 'Opção B');
      },
    );

    testWidgets('Fecha o overlay ao tocar fora do menu (barrier)', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          AppDropdown<String>(
            hintText: 'Escolha',
            value: null,
            items: options,
            onChanged: (_) {},
          ),
        ),
      );

      await tester.tap(find.text('Escolha'));
      await tester.pumpAndSettle();
      expect(find.text('Opção A'), findsOneWidget);

      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(find.text('Opção A'), findsNothing);
    });

    testWidgets('Respeita estado desabilitado (enabled = false)', (
      tester,
    ) async {
      bool called = false;

      await tester.pumpWidget(
        buildTestableWidget(
          AppDropdown<String>(
            enabled: false,
            hintText: 'Desabilitado',
            value: null,
            items: options,
            onChanged: (_) => called = true,
          ),
        ),
      );

      await tester.tap(find.text('Desabilitado'));
      await tester.pumpAndSettle();

      expect(find.text('Opção A'), findsNothing);
      expect(called, isFalse);
    });

    testWidgets('Cobre didUpdateWidget e desabilitação dinâmica', (
      tester,
    ) async {
      bool enabled = true;
      String? value;

      await tester.pumpWidget(
        buildTestableWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return Column(
                children: [
                  AppDropdown<String>(
                    enabled: enabled,
                    value: value,
                    items: options,
                    onChanged: (val) => setState(() => value = val),
                  ),
                  ElevatedButton(
                    onPressed: () => setState(() => enabled = false),
                    child: const Text('Desabilitar'),
                  ),
                  ElevatedButton(
                    onPressed: () => setState(() => value = 'Opção A'),
                    child: const Text('Atualizar Valor'),
                  ),
                ],
              );
            },
          ),
        ),
      );

      // 1. Abre o menu do dropdown
      await tester.tap(find.byType(AppDropdown<String>));
      await tester.pumpAndSettle();

      // Confirma que as opções do menu estão visíveis no overlay
      expect(find.text('Opção A'), findsWidgets);
      expect(find.text('Opção B'), findsOneWidget);

      // 2. Atualiza o valor externamente enquanto aberto (força o markNeedsBuild no didUpdateWidget)
      await tester.tap(find.text('Atualizar Valor'));
      await tester.pumpAndSettle();

      // 3. Desabilita o widget via didUpdateWidget (deve acionar o _close())
      await tester.tap(find.text('Desabilitar'));
      await tester.pumpWidget(
        buildTestableWidget(
          AppDropdown<String>(
            enabled: false,
            value: 'Opção A',
            items: options,
            onChanged: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Garante que as opções do overlay ('Opção B' e 'Opção C') foram removidas
      expect(find.text('Opção B'), findsNothing);
      expect(find.text('Opção C'), findsNothing);
    });

    testWidgets(
      'Cobre dispose com overlay aberto e fallback de item.toString()',
      (tester) async {
        await tester.pumpWidget(
          buildTestableWidget(
            AppDropdown<int>(
              hintText: 'Números',
              value: null,
              items: const [10, 20, 30],
              onChanged: (_) {},
            ),
          ),
        );

        await tester.tap(find.text('Números'));
        await tester.pumpAndSettle();
        expect(find.text('10'), findsOneWidget);

        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: SizedBox())),
        );
        await tester.pumpAndSettle();
      },
    );
  });
}
