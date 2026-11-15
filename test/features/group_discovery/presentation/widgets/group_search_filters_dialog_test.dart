import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/cities/domain/entities/discovery_city_entity.dart';
import 'package:mobile/features/group_discovery/domain/entities/group_search_filters.dart';
import 'package:mobile/features/group_discovery/presentation/widgets/group_search_filters_dialog.dart';
import 'package:mobile/features/cities/presentation/widgets/city_filter_dropdown.dart';
import 'package:mobile/l10n/app_localizations.dart';

import '../../../cities/cities_fixtures.dart';

void main() {
  Finder cityDropdown() => find.byType(CityFilterDropdown);

  /// Abre o modal e devolve como ler o que ele retornou ao fechar.
  Future<GroupSearchFilters? Function()> openDialog(
    WidgetTester tester, {
    required GroupSearchFilters initial,
    required List<DiscoveryCityEntity>? cities,
  }) async {
    GroupSearchFilters? result;
    var closed = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('pt', 'BR'),
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              result = await GroupSearchFiltersDialog.show(
                context,
                initial: initial,
                cities: cities,
              );
              closed = true;
            },
            child: const Text('abrir'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    return () {
      expect(closed, isTrue);
      return result;
    };
  }

  testWidgets('opens with the applied filters filled in', (tester) async {
    final read = await openDialog(
      tester,
      initial: const GroupSearchFilters(
        city: saoPaulo,
        minParticipants: 10,
        maxParticipants: 20,
      ),
      cities: const [portoAlegre, saoPaulo],
    );

    expect(
      find.descendant(of: cityDropdown(), matching: find.text('São Paulo, SP')),
      findsOneWidget,
    );
    expect(find.text('10'), findsOneWidget);
    expect(find.text('20'), findsOneWidget);

    await tester.tap(find.text('Aplicar filtros'));
    await tester.pumpAndSettle();

    expect(
      read(),
      const GroupSearchFilters(
        city: saoPaulo,
        minParticipants: 10,
        maxParticipants: 20,
      ),
    );
  });

  testWidgets('starts on "Todas as cidades" and applies the chosen city', (
    tester,
  ) async {
    final read = await openDialog(
      tester,
      initial: GroupSearchFilters.empty,
      cities: const [portoAlegre, saoPaulo],
    );

    expect(
      find.descendant(
        of: cityDropdown(),
        matching: find.text('Todas as cidades'),
      ),
      findsOneWidget,
    );

    await tester.tap(cityDropdown());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Porto Alegre, RS').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Aplicar filtros'));
    await tester.pumpAndSettle();

    expect(read(), const GroupSearchFilters(city: portoAlegre));
  });

  testWidgets('hides the city filter when the city list did not load', (
    tester,
  ) async {
    final read = await openDialog(
      tester,
      initial: const GroupSearchFilters(minParticipants: 3),
      cities: null,
    );

    expect(cityDropdown(), findsNothing);
    expect(find.text('Cidade'), findsNothing);

    await tester.tap(find.text('Aplicar filtros'));
    await tester.pumpAndSettle();

    expect(read(), const GroupSearchFilters(minParticipants: 3));
  });

  testWidgets('"Limpar filtros" returns no filter', (tester) async {
    final read = await openDialog(
      tester,
      initial: const GroupSearchFilters(city: portoAlegre, minParticipants: 3),
      cities: const [portoAlegre],
    );

    await tester.tap(find.text('Limpar filtros'));
    await tester.pumpAndSettle();

    expect(read(), GroupSearchFilters.empty);
  });

  testWidgets('the actions and the city filter have a 48 touch target', (
    tester,
  ) async {
    await openDialog(
      tester,
      initial: GroupSearchFilters.empty,
      cities: const [portoAlegre],
    );

    for (final label in ['Limpar filtros', 'Aplicar filtros']) {
      expect(
        tester.getSize(find.widgetWithText(AppButton, label)).height,
        greaterThanOrEqualTo(48),
      );
    }
    expect(
      tester
          .getSize(
            find.descendant(of: cityDropdown(), matching: find.byType(InkWell)),
          )
          .height,
      greaterThanOrEqualTo(48),
    );
  });
}
