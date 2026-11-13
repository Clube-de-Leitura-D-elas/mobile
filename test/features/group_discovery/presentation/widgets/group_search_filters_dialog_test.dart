import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/group_discovery/domain/entities/group_genre_entity.dart';
import 'package:mobile/features/group_discovery/domain/entities/group_search_filters.dart';
import 'package:mobile/features/group_discovery/presentation/widgets/group_search_filters_dialog.dart';
import 'package:mobile/l10n/app_localizations.dart';

void main() {
  const fiction = GroupGenreEntity(id: 'g-1', name: 'Ficção');
  const adventure = GroupGenreEntity(id: 'g-2', name: 'Aventura');

  /// Abre o modal e devolve como ler o que ele retornou ao fechar.
  Future<GroupSearchFilters? Function()> openDialog(
    WidgetTester tester, {
    required GroupSearchFilters initial,
    required List<GroupGenreEntity> genres,
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
                genres: genres,
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
        genre: adventure,
        minParticipants: 10,
        maxParticipants: 20,
      ),
      genres: const [fiction, adventure],
    );

    expect(
      find.descendant(
        of: find.byType(AppDropdown<GroupGenreEntity?>),
        matching: find.text('Aventura'),
      ),
      findsOneWidget,
    );
    expect(find.text('10'), findsOneWidget);
    expect(find.text('20'), findsOneWidget);

    await tester.tap(find.text('Aplicar filtros'));
    await tester.pumpAndSettle();

    expect(
      read(),
      const GroupSearchFilters(
        genre: adventure,
        minParticipants: 10,
        maxParticipants: 20,
      ),
    );
  });

  testWidgets('keeps the applied genre when the genre list is not loaded', (
    tester,
  ) async {
    final read = await openDialog(
      tester,
      initial: const GroupSearchFilters(genre: fiction),
      genres: const [],
    );

    expect(find.text('Ficção'), findsOneWidget);

    await tester.tap(find.text('Aplicar filtros'));
    await tester.pumpAndSettle();

    expect(read(), const GroupSearchFilters(genre: fiction));
  });

  testWidgets('"Limpar filtros" returns no filter', (tester) async {
    final read = await openDialog(
      tester,
      initial: const GroupSearchFilters(genre: fiction, minParticipants: 3),
      genres: const [fiction],
    );

    await tester.tap(find.text('Limpar filtros'));
    await tester.pumpAndSettle();

    expect(read(), GroupSearchFilters.empty);
  });

  testWidgets('the actions have a 48 touch target', (tester) async {
    await openDialog(
      tester,
      initial: GroupSearchFilters.empty,
      genres: const [],
    );

    for (final label in ['Limpar filtros', 'Aplicar filtros']) {
      expect(
        tester.getSize(find.widgetWithText(AppButton, label)).height,
        greaterThanOrEqualTo(48),
      );
    }
  });
}
