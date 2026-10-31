import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/l10n/app_localizations.dart';

Future<void> _pumpChip(
  WidgetTester tester,
  AppReadingStatusChip chip, {
  bool localized = false,
}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      locale: localized ? const Locale('pt') : null,
      localizationsDelegates: localized
          ? AppLocalizations.localizationsDelegates
          : null,
      supportedLocales: localized
          ? AppLocalizations.supportedLocales
          : const [Locale('en', 'US')],
      home: Scaffold(body: Center(child: chip)),
    ),
  );
}

AppChip _chip(WidgetTester tester) =>
    tester.widget<AppChip>(find.byType(AppChip));

void main() {
  group('AppReadingStatusChip', () {
    testWidgets('Read state is filled with the "Já lido" label', (
      tester,
    ) async {
      await _pumpChip(
        tester,
        const AppReadingStatusChip(state: ReadingStatusChipState.read),
      );

      expect(_chip(tester).variant, AppChipVariant.filled);
      expect(find.text('Já lido'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('Want-to-read state is outlined with the "Quero ler" label', (
      tester,
    ) async {
      await _pumpChip(
        tester,
        const AppReadingStatusChip(state: ReadingStatusChipState.wantToRead),
      );

      expect(_chip(tester).variant, AppChipVariant.outlined);
      expect(find.text('Quero ler'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });

    testWidgets(
      'Mark-as-read state is outlined with the "Marcar como lido" label',
      (tester) async {
        await _pumpChip(
          tester,
          const AppReadingStatusChip(state: ReadingStatusChipState.markAsRead),
        );

        expect(_chip(tester).variant, AppChipVariant.outlined);
        expect(find.text('Marcar como lido'), findsOneWidget);
        expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
      },
    );

    testWidgets('Uses the localized labels when l10n is available', (
      tester,
    ) async {
      for (final state in ReadingStatusChipState.values) {
        await _pumpChip(
          tester,
          AppReadingStatusChip(state: state),
          localized: true,
        );

        final l10n = AppLocalizations.of(tester.element(find.byType(AppChip)));
        final expected = switch (state) {
          ReadingStatusChipState.read => l10n.readingStatusRead,
          ReadingStatusChipState.wantToRead => l10n.readingStatusWantToRead,
          ReadingStatusChipState.markAsRead => l10n.readingStatusMarkAsRead,
        };

        expect(_chip(tester).label, expected);
      }
    });

    testWidgets('Forwards onTap and isLoading to the AppChip', (tester) async {
      var taps = 0;
      await _pumpChip(
        tester,
        AppReadingStatusChip(
          state: ReadingStatusChipState.wantToRead,
          onTap: () => taps++,
        ),
      );

      await tester.tap(find.byType(AppReadingStatusChip));
      expect(taps, 1);

      await _pumpChip(
        tester,
        AppReadingStatusChip(
          state: ReadingStatusChipState.wantToRead,
          isLoading: true,
          onTap: () => taps++,
        ),
      );

      expect(_chip(tester).isLoading, isTrue);
    });
  });
}
