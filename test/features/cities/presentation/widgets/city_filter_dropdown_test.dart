import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/cities/domain/entities/discovery_city_entity.dart';
import 'package:mobile/features/cities/presentation/widgets/city_filter_dropdown.dart';
import 'package:mobile/l10n/app_localizations.dart';

import '../../cities_fixtures.dart';

void main() {
  Future<List<DiscoveryCityEntity?>> pump(
    WidgetTester tester, {
    DiscoveryCityEntity? value,
  }) async {
    final changes = <DiscoveryCityEntity?>[];
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('pt', 'BR'),
        home: Scaffold(
          body: CityFilterDropdown(
            cities: const [portoAlegre, saoPaulo],
            value: value,
            onChanged: changes.add,
          ),
        ),
      ),
    );
    return changes;
  }

  testWidgets('lists "Todas as cidades" first, then the cities', (
    tester,
  ) async {
    await pump(tester, value: portoAlegre);

    expect(find.text('Cidade'), findsOneWidget);
    expect(find.text('Porto Alegre, RS'), findsOneWidget);

    await tester.tap(find.byType(CityFilterDropdown));
    await tester.pumpAndSettle();

    final options = find.byWidgetPredicate(
      (widget) => widget is Text && widget.style?.fontWeight != null,
    );
    expect(
      tester.widgetList<Text>(options).map((text) => text.data),
      containsAllInOrder([
        'Todas as cidades',
        'Porto Alegre, RS',
        'São Paulo, SP',
      ]),
    );
  });

  testWidgets('announces the selected option as its value', (tester) async {
    await pump(tester, value: portoAlegre);
    final nodeP = tester.getSemantics(find.byType(CityFilterDropdown));
    expect(nodeP.value, 'Porto Alegre, RS');
    expect(nodeP.flagsCollection.isButton, isTrue);

    await pump(tester);
    final nodeT = tester.getSemantics(find.byType(CityFilterDropdown));
    expect(nodeT.value, 'Todas as cidades');
    expect(nodeT.flagsCollection.isButton, isTrue);
  });

  testWidgets('"Todas as cidades" is the null option', (tester) async {
    final changes = await pump(tester, value: saoPaulo);

    await tester.tap(find.byType(CityFilterDropdown));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Todas as cidades'));
    await tester.pumpAndSettle();

    expect(changes, [null]);
  });

  testWidgets('picking a city reports it', (tester) async {
    final changes = await pump(tester);

    expect(find.text('Todas as cidades'), findsOneWidget);

    await tester.tap(find.byType(CityFilterDropdown));
    await tester.pumpAndSettle();
    await tester.tap(find.text('São Paulo, SP'));
    await tester.pumpAndSettle();

    expect(changes, [saoPaulo]);
  });
}
