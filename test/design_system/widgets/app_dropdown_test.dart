import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/l10n/app_localizations.dart';

void main() {
  // Carrega o AppLocalizations uma vez (não depende de BuildContext aqui,
  // só precisamos dos valores das strings) e monta a lista de itens a
  // partir dele — nada de literal 'Romance'/'Fantasia' hardcoded no teste.
  late AppLocalizations l10n;
  late List<String> items;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('pt', 'BR'));
    items = [
      l10n.genreRomance,
      l10n.genreFantasy,
      l10n.genreSuspense,
      l10n.genreNonFiction,
    ];
  });

  Widget wrap(Widget child, {ThemeData? theme}) {
    return MaterialApp(
      theme: theme ?? AppTheme.light,
      home: Scaffold(body: Center(child: child)),
    );
  }

  testWidgets('Estado fechado exibe o hintText quando value é null', (tester) async {
    await tester.pumpWidget(wrap(AppDropdown<String>(
      items: items,
      value: null,
      hintText: l10n.genreFieldHint,
      onChanged: (_) {},
    )));

    expect(find.text(l10n.genreFieldHint), findsOneWidget);
    expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);
  });

  testWidgets('Estado com item selecionado exibe o rótulo correspondente', (tester) async {
    await tester.pumpWidget(wrap(AppDropdown<String>(
      items: items,
      value: l10n.genreFantasy,
      onChanged: (_) {},
    )));

    expect(find.text(l10n.genreFantasy), findsOneWidget);
  });

  testWidgets('Tocar no trigger abre o menu (estado aberto)', (tester) async {
    await tester.pumpWidget(wrap(AppDropdown<String>(
      items: items,
      value: null,
      onChanged: (_) {},
    )));

    await tester.tap(find.byType(AppDropdown<String>));
    await tester.pumpAndSettle();

    expect(find.text(l10n.genreRomance), findsOneWidget);
    expect(find.text(l10n.genreFantasy), findsOneWidget);
    expect(find.text(l10n.genreSuspense), findsOneWidget);
    expect(find.text(l10n.genreNonFiction), findsOneWidget);
    expect(find.byIcon(Icons.keyboard_arrow_up), findsOneWidget);
  });

  testWidgets(
    'Given o menu aberto, When escolho uma opção, Then fecha e atualiza o valor',
    (tester) async {
      String? selected;

      await tester.pumpWidget(wrap(StatefulBuilder(
        builder: (context, setState) => AppDropdown<String>(
          items: items,
          value: selected,
          onChanged: (value) => setState(() => selected = value),
        ),
      )));

      await tester.tap(find.byType(AppDropdown<String>));
      await tester.pumpAndSettle();

      await tester.tap(find.text(l10n.genreSuspense));
      await tester.pumpAndSettle();

      expect(selected, l10n.genreSuspense);
      // Menu fechado: só sobra o rótulo no trigger, não mais na lista.
      expect(find.text(l10n.genreRomance), findsNothing);
    },
  );

  testWidgets(
    'Given o menu aberto, When toco fora, Then fecha sem mudar o valor',
    (tester) async {
      String? selected = l10n.genreRomance;

      await tester.pumpWidget(wrap(StatefulBuilder(
        builder: (context, setState) => AppDropdown<String>(
          items: items,
          value: selected,
          onChanged: (value) => setState(() => selected = value),
        ),
      )));

      await tester.tap(find.byType(AppDropdown<String>));
      await tester.pumpAndSettle();

      // Toca num ponto fora do menu (barreira translúcida cobrindo a tela).
      await tester.tapAt(const Offset(5.0, 5.0));
      await tester.pumpAndSettle();

      expect(selected, l10n.genreRomance);
      expect(find.text(l10n.genreFantasy), findsNothing);
    },
  );

  testWidgets('Estado desabilitado não abre o menu ao tocar', (tester) async {
    await tester.pumpWidget(wrap(AppDropdown<String>(
      items: items,
      value: l10n.genreRomance,
      enabled: false,
      onChanged: (_) {},
    )));

    await tester.tap(find.byType(AppDropdown<String>));
    await tester.pumpAndSettle();

    expect(find.text(l10n.genreFantasy), findsNothing);
  });

  testWidgets('itemLabelBuilder define o rótulo exibido quando informado', (tester) async {
    await tester.pumpWidget(wrap(AppDropdown<int>(
      items: const [1, 2, 3],
      value: 2,
      itemLabelBuilder: (item) => 'Opção $item',
      onChanged: (_) {},
    )));

    expect(find.text('Opção 2'), findsOneWidget);
  });

  testWidgets('Funciona em modo escuro (AppTheme.dark) sem quebrar', (tester) async {
    await tester.pumpWidget(wrap(
      AppDropdown<String>(
        items: items,
        value: l10n.genreRomance,
        onChanged: (_) {},
      ),
      theme: AppTheme.dark,
    ));

    await tester.tap(find.byType(AppDropdown<String>));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text(l10n.genreFantasy), findsOneWidget);
  });

  testWidgets('AppDropdownSize.lg aplica altura de 56px ao trigger', (tester) async {
    await tester.pumpWidget(wrap(AppDropdown<String>(
      items: items,
      value: null,
      size: AppDropdownSize.lg,
      onChanged: (_) {},
    )));

    final size = tester.getSize(find.byType(AppDropdown<String>));
    expect(size.height, 56.0);
  });
}