import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/l10n/app_localizations.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: AppTheme.light,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);

void main() {
  group('AppErrorState', () {
    testWidgets('shows the message without buttons when there is no retry', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const AppErrorState(message: 'Algo deu errado.')),
      );

      expect(find.text('Algo deu errado.'), findsOneWidget);
      expect(find.byType(AppButton), findsNothing);
    });

    testWidgets('retry button calls onRetry', (tester) async {
      var retries = 0;
      await tester.pumpWidget(
        _wrap(AppErrorState(message: 'Falhou.', onRetry: () => retries++)),
      );

      await tester.tap(find.text('Tentar novamente'));

      expect(retries, 1);
    });

    testWidgets('secondary action shows only with label and callback', (
      tester,
    ) async {
      var secondary = 0;
      await tester.pumpWidget(
        _wrap(
          AppErrorState(
            message: 'Falhou.',
            onRetry: () {},
            secondaryLabel: 'Sair',
            onSecondary: () => secondary++,
          ),
        ),
      );

      await tester.tap(find.text('Sair'));

      expect(secondary, 1);
      expect(find.byType(AppButton), findsNWidgets(2));
    });

    testWidgets('announces the message as a live region', (tester) async {
      await tester.pumpWidget(_wrap(const AppErrorState(message: 'Falhou.')));

      final semantics = tester.getSemantics(find.text('Falhou.'));
      expect(semantics.flagsCollection.isLiveRegion, isTrue);
    });
  });
}
