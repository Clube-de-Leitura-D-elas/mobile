import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/raffles/presentation/widgets/confirm_raffle_dialog.dart';
import 'package:mobile/l10n/app_localizations.dart';

void main() {
  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      theme: AppTheme.light,
      locale: const Locale('pt', 'BR'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(body: child),
    );
  }

  testWidgets('ConfirmRaffleDialog chama onConfirm ao clicar em Confirmar', (
    tester,
  ) async {
    bool confirmed = false;

    await tester.pumpWidget(
      buildTestableWidget(
        ConfirmRaffleDialog(
          onConfirm: () {
            confirmed = true;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Confirmar sorteio'), findsOneWidget);
    expect(find.text('Você deseja mesmo confirmar o sorteio?'), findsOneWidget);

    final confirmButton = find.text('Confirmar');
    await tester.tap(confirmButton);
    await tester.pumpAndSettle();

    expect(confirmed, isTrue);
  });

  testWidgets('ConfirmRaffleDialog fecha ao clicar no botão fechar (X)', (
    tester,
  ) async {
    bool? result;

    await tester.pumpWidget(
      buildTestableWidget(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await ConfirmRaffleDialog.show(context);
            },
            child: const Text('Open Dialog'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    final closeIcon = find.byIcon(Icons.close);
    expect(closeIcon, findsOneWidget);

    // Verifica que o IconButton tem dimensões acessíveis (pelo menos 48x48)
    final iconButtonFinder = find.ancestor(
      of: closeIcon,
      matching: find.byType(SizedBox),
    );
    final sizedBox = tester.widget<SizedBox>(iconButtonFinder.first);
    expect(sizedBox.width, 48.0);
    expect(sizedBox.height, 48.0);

    await tester.tap(closeIcon);
    await tester.pumpAndSettle();

    expect(result, isFalse);
    expect(find.byType(ConfirmRaffleDialog), findsNothing);
  });

  testWidgets('ConfirmRaffleDialog fecha ao clicar no botão Cancelar', (
    tester,
  ) async {
    bool? result;

    await tester.pumpWidget(
      buildTestableWidget(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await ConfirmRaffleDialog.show(context);
            },
            child: const Text('Open Dialog'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    final cancelButton = find.text('Cancelar');
    await tester.tap(cancelButton);
    await tester.pumpAndSettle();

    expect(result, isFalse);
    expect(find.byType(ConfirmRaffleDialog), findsNothing);
  });
}
