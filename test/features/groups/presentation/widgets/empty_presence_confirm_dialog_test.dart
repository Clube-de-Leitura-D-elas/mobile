import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/presentation/widgets/empty_presence_confirm_dialog.dart';
import 'package:mobile/l10n/app_localizations.dart';

void main() {
  Future<Future<bool?>> pumpAndOpen(WidgetTester tester) async {
    late Future<bool?> result;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('pt'),
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () =>
                  result = EmptyPresenceConfirmDialog.show(context),
              child: const Text('abrir'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    return result;
  }

  testWidgets('explica que todas ficam com falta e não dá para refazer', (
    tester,
  ) async {
    await pumpAndOpen(tester);

    expect(find.byType(AppDialog), findsOneWidget);
    expect(find.text('Ninguém compareceu?'), findsOneWidget);
    expect(
      find.text(
        'Nenhuma participante está marcada. Ao confirmar, todas ficam com '
        'falta e a lista não pode ser alterada depois.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('confirmar devolve true', (tester) async {
    final result = await pumpAndOpen(tester);

    await tester.tap(find.text('Confirmar mesmo assim'));
    await tester.pumpAndSettle();

    expect(await result, isTrue);
    expect(find.byType(EmptyPresenceConfirmDialog), findsNothing);
  });

  testWidgets('voltar e o x devolvem false', (tester) async {
    var result = await pumpAndOpen(tester);
    await tester.tap(find.text('Voltar'));
    await tester.pumpAndSettle();
    expect(await result, isFalse);

    result = await pumpAndOpen(tester);
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(await result, isFalse);
  });
}
