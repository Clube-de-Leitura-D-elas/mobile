import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/books/presentation/widgets/group_select_tile.dart';
import 'package:mobile/features/groups/presentation/widgets/app_group_avatar.dart';
import 'package:mobile/l10n/app_localizations.dart';

/// Luminância × 0,7. Fica no teste, fora do widget, para o teste falhar
/// se o tom da foto mudar.
const _alreadySuggestedPhotoMatrix = <double>[
  0.149,
  0.501,
  0.051,
  0,
  0,
  0.149,
  0.501,
  0.051,
  0,
  0,
  0.149,
  0.501,
  0.051,
  0,
  0,
  0,
  0,
  0,
  1,
  0,
];

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
      GroupSelectTile(
        name: 'Grupo 1',
        photoUrl: 'https://example.com/grupo.png',
        onTap: () => taps++,
      ),
    );

    expect(find.text('já indicado'), findsNothing);
    expect(find.byType(ColorFiltered), findsNothing);
    expect(find.bySemanticsLabel('Grupo 1'), findsOneWidget);
    final avatar = tester.widget<AppGroupAvatar>(find.byType(AppGroupAvatar));
    expect(avatar.diameter, 48);
    expect(avatar.photoUrl, 'https://example.com/grupo.png');
    final availableName = tester.widget<Text>(find.text('Grupo 1'));
    final availableContext = tester.element(find.text('Grupo 1'));
    expect(
      availableName.style,
      availableContext.typography.headingH3.copyWith(
        color: availableContext.colors.textDefault,
      ),
    );

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
    expect(
      tester.widget<AppGroupAvatar>(find.byType(AppGroupAvatar)).diameter,
      48,
    );
    final suggestedName = tester.widget<Text>(find.text('Grupo 14'));
    final suggestedContext = tester.element(find.text('Grupo 14'));
    expect(
      suggestedName.style,
      suggestedContext.typography.headingH3.copyWith(
        color: suggestedContext.colors.textMuted,
      ),
    );
    expect(
      tester.widget<ColorFiltered>(find.byType(ColorFiltered)).colorFilter,
      const ColorFilter.matrix(_alreadySuggestedPhotoMatrix),
    );
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
