import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/design_system/design_system.dart';

void main() {
  testWidgets('showAppToast displays info toast correctly', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => context.showAppToast('Mensagem de teste'),
                child: const Text('Exibir Toast'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Exibir Toast'));
    await tester.pump();

    expect(find.text('Mensagem de teste'), findsOneWidget);
  });

  testWidgets('showSuccessToast displays success toast correctly', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => context.showSuccessToast('Salvo com sucesso'),
                child: const Text('Sucesso'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Sucesso'));
    await tester.pump();

    expect(find.text('Salvo com sucesso'), findsOneWidget);
  });

  testWidgets('showErrorToast displays error toast correctly', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () =>
                    context.showErrorToast('Erro ao carregar dados'),
                child: const Text('Erro'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Erro'));
    await tester.pump();

    expect(find.text('Erro ao carregar dados'), findsOneWidget);
  });

  testWidgets('showWarningToast displays warning toast correctly', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => context.showWarningToast('Atenção'),
                child: const Text('Aviso'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Aviso'));
    await tester.pump();

    expect(find.text('Atenção'), findsOneWidget);
  });

  testWidgets('showInfoToast displays info toast correctly', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => context.showInfoToast('Informação'),
                child: const Text('Info'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Info'));
    await tester.pump();

    expect(find.text('Informação'), findsOneWidget);
  });
}
