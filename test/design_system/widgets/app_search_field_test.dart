import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/l10n/app_localizations.dart';

const _hint = 'Que livro vamos devorar hoje?';

Future<void> _pumpField(WidgetTester tester, AppSearchField field) {
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt'),
      home: Scaffold(body: Center(child: field)),
    ),
  );
}

Finder get _clearButton => find.byTooltip('Limpar busca');

void main() {
  group('AppSearchField', () {
    testWidgets('Shows the configured hint text', (tester) async {
      await _pumpField(tester, const AppSearchField(hintText: _hint));

      expect(find.text(_hint), findsOneWidget);
    });

    testWidgets('Debounces onChanged by 300 ms by default', (tester) async {
      final calls = <String>[];

      await _pumpField(
        tester,
        AppSearchField(hintText: _hint, onChanged: calls.add),
      );

      await tester.enterText(find.byType(TextField), 'Du');
      await tester.pump(const Duration(milliseconds: 200));
      await tester.enterText(find.byType(TextField), 'Duna');
      await tester.pump(const Duration(milliseconds: 299));

      expect(calls, isEmpty);

      await tester.pump(const Duration(milliseconds: 1));

      expect(calls, ['Duna']);
    });

    testWidgets('Uses a custom debounce duration', (tester) async {
      final calls = <String>[];

      await _pumpField(
        tester,
        AppSearchField(
          hintText: _hint,
          debounce: const Duration(milliseconds: 50),
          onChanged: calls.add,
        ),
      );

      await tester.enterText(find.byType(TextField), 'Duna');
      await tester.pump(const Duration(milliseconds: 50));

      expect(calls, ['Duna']);
    });

    testWidgets('Submitting from the keyboard skips the debounce', (
      tester,
    ) async {
      final calls = <String>[];

      await _pumpField(
        tester,
        AppSearchField(hintText: _hint, onChanged: calls.add),
      );

      await tester.enterText(find.byType(TextField), 'Duna');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();

      expect(calls, ['Duna']);

      // O debounce pendente foi cancelado: não chama de novo.
      await tester.pump(AppSearchField.defaultDebounce);

      expect(calls, ['Duna']);
    });

    testWidgets('Keeps the text when the external controller is removed', (
      tester,
    ) async {
      final controller = TextEditingController(text: 'Duna');
      addTearDown(controller.dispose);

      await _pumpField(
        tester,
        AppSearchField(hintText: _hint, controller: controller),
      );
      await _pumpField(tester, const AppSearchField(hintText: _hint));

      expect(find.text('Duna'), findsOneWidget);
      expect(_clearButton, findsOneWidget);
    });

    testWidgets('Hides the clear button while the field is empty', (
      tester,
    ) async {
      await _pumpField(tester, const AppSearchField(hintText: _hint));

      expect(_clearButton, findsNothing);

      await tester.enterText(find.byType(TextField), 'Duna');
      await tester.pump();

      expect(_clearButton, findsOneWidget);
    });

    testWidgets('Clear empties the field and reports an empty query now', (
      tester,
    ) async {
      final calls = <String>[];

      await _pumpField(
        tester,
        AppSearchField(hintText: _hint, onChanged: calls.add),
      );

      await tester.enterText(find.byType(TextField), 'Duna');
      await tester.pump();
      await tester.tap(_clearButton);
      await tester.pump();

      expect(calls, ['']);
      expect(find.text('Duna'), findsNothing);
      expect(find.text(_hint), findsOneWidget);
      expect(_clearButton, findsNothing);

      // O debounce pendente da digitação foi cancelado pelo limpar.
      await tester.pump(AppSearchField.defaultDebounce);

      expect(calls, ['']);
    });

    testWidgets('Clears an external controller', (tester) async {
      final controller = TextEditingController(text: 'Duna');
      addTearDown(controller.dispose);

      await _pumpField(
        tester,
        AppSearchField(hintText: _hint, controller: controller),
      );

      expect(_clearButton, findsOneWidget);

      await tester.tap(_clearButton);
      await tester.pump();

      expect(controller.text, isEmpty);
    });

    testWidgets('Clear button has a 48x48 tap target and a semantic label', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();

      await _pumpField(tester, const AppSearchField(hintText: _hint));
      await tester.enterText(find.byType(TextField), 'Duna');
      await tester.pump();

      expect(
        tester.getSize(find.byType(IconButton)),
        const Size(AppSearchField.height, AppSearchField.height),
      );
      expect(
        tester.getSemantics(find.byType(IconButton)),
        isSemantics(
          tooltip: 'Limpar busca',
          isButton: true,
          hasTapAction: true,
        ),
      );

      semantics.dispose();
    });
  });
}
