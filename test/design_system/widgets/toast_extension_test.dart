import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/design_system/design_system.dart';

void main() {
  Widget wrap(WidgetBuilder builder) {
    return MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: Builder(builder: builder)),
    );
  }

  Future<void> tapAndPump(WidgetTester tester) async {
    await tester.tap(find.text('disparar'));
    await tester.pump();
  }

  testWidgets('context.showToast exibe a mensagem e usa o type informado', (tester) async {
    await tester.pumpWidget(wrap((context) {
      return ElevatedButton(
        onPressed: () => context.showToast('Mensagem genérica', type: AppToastType.warning),
        child: const Text('disparar'),
      );
    }));

    await tapAndPump(tester);

    expect(find.text('Mensagem genérica'), findsOneWidget);
    expect(find.byIcon(Icons.warning_amber_outlined), findsOneWidget);
  });

  testWidgets('context.showToast usa AppToastType.info como padrão quando type não é informado', (tester) async {
    await tester.pumpWidget(wrap((context) {
      return ElevatedButton(
        onPressed: () => context.showToast('Padrão'),
        child: const Text('disparar'),
      );
    }));

    await tapAndPump(tester);

    expect(find.byIcon(Icons.info_outline), findsOneWidget);
  });

  testWidgets('context.showSuccessToast usa AppToastType.success', (tester) async {
    await tester.pumpWidget(wrap((context) {
      return ElevatedButton(
        onPressed: () => context.showSuccessToast('Salvo com sucesso'),
        child: const Text('disparar'),
      );
    }));

    await tapAndPump(tester);

    expect(find.text('Salvo com sucesso'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
  });

  testWidgets('context.showErrorToast usa AppToastType.error', (tester) async {
    await tester.pumpWidget(wrap((context) {
      return ElevatedButton(
        onPressed: () => context.showErrorToast('Não foi possível salvar os dados.'),
        child: const Text('disparar'),
      );
    }));

    await tapAndPump(tester);

    expect(find.text('Não foi possível salvar os dados.'), findsOneWidget);
    expect(find.byIcon(Icons.cancel_outlined), findsOneWidget);
  });

  testWidgets('context.showWarningToast usa AppToastType.warning', (tester) async {
    await tester.pumpWidget(wrap((context) {
      return ElevatedButton(
        onPressed: () => context.showWarningToast('Atenção'),
        child: const Text('disparar'),
      );
    }));

    await tapAndPump(tester);

    expect(find.text('Atenção'), findsOneWidget);
    expect(find.byIcon(Icons.warning_amber_outlined), findsOneWidget);
  });

  testWidgets('context.showInfoToast usa AppToastType.info', (tester) async {
    await tester.pumpWidget(wrap((context) {
      return ElevatedButton(
        onPressed: () => context.showInfoToast('Só um aviso'),
        child: const Text('disparar'),
      );
    }));

    await tapAndPump(tester);

    expect(find.text('Só um aviso'), findsOneWidget);
    expect(find.byIcon(Icons.info_outline), findsOneWidget);
  });

  testWidgets('respeita a duration customizada e remove o toast depois dela', (tester) async {
    await tester.pumpWidget(wrap((context) {
      return ElevatedButton(
        onPressed: () => context.showToast(
          'Some rápido',
          duration: const Duration(milliseconds: 500),
        ),
        child: const Text('disparar'),
      );
    }));

    await tapAndPump(tester);
    expect(find.text('Some rápido'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Some rápido'), findsNothing);
  });

  testWidgets('usa 3 segundos como duration padrão quando não informada', (tester) async {
    await tester.pumpWidget(wrap((context) {
      return ElevatedButton(
        onPressed: () => context.showToast('Padrão de duração'),
        child: const Text('disparar'),
      );
    }));

    await tapAndPump(tester);
    expect(find.text('Padrão de duração'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2, milliseconds: 900));
    expect(find.text('Padrão de duração'), findsOneWidget, reason: 'ainda não deveria ter sumido antes dos 3s');

    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Padrão de duração'), findsNothing);
  });
}
