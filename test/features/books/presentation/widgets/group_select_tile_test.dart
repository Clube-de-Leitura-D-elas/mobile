import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/books/presentation/widgets/group_select_tile.dart';
import 'package:mobile/l10n/app_localizations.dart';

Future<void> _pumpTile(WidgetTester tester, GroupSelectTile tile) {
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      locale: const Locale('pt'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: tile),
    ),
  );
}

void main() {
  testWidgets('an available group calls onTap and hides the tag', (
    tester,
  ) async {
    var taps = 0;

    await _pumpTile(
      tester,
      GroupSelectTile(name: 'Grupo 1', onTap: () => taps++),
    );

    expect(find.text('já indicado'), findsNothing);
    expect(find.bySemanticsLabel('Grupo 1'), findsOneWidget);

    await tester.tap(find.text('Grupo 1'));
    await tester.pump();
    expect(taps, 1);
  });

  testWidgets('an already suggested group shows the tag and ignores taps', (
    tester,
  ) async {
    var taps = 0;

    await _pumpTile(
      tester,
      GroupSelectTile(
        name: 'Grupo 14',
        alreadySuggested: true,
        onTap: () => taps++,
      ),
    );

    expect(find.text('já indicado'), findsOneWidget);
    expect(find.byType(AppTag), findsOneWidget);
    expect(
      tester.widget<AppTag>(find.byType(AppTag)).variant,
      TagVariant.neutral,
    );
    expect(find.bySemanticsLabel('Grupo 14, já indicado'), findsOneWidget);

    await tester.tap(find.text('Grupo 14'));
    await tester.pump();
    expect(taps, 0);
  });
}
