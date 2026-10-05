import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/groups/presentation/widgets/app_meeting_response_buttons.dart';
import 'package:mobile/l10n/app_localizations.dart';

void main() {
  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt'),
      home: Scaffold(body: child),
    );
  }

  group('AppMeetingResponseButtons', () {
    testWidgets('Deve exibir ambos os botões no estado inicial', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(const AppMeetingResponseButtons()),
      );
      await tester.pumpAndSettle();

      final BuildContext context = tester.element(
        find.byType(AppMeetingResponseButtons),
      );
      final l10n = AppLocalizations.of(context);

      expect(find.text(l10n.groupDeclineMeetingButton), findsOneWidget);
      expect(find.text(l10n.groupConfirmMeetingButton), findsOneWidget);
    });

    testWidgets('Deve alternar para o botão de recusar ao confirmar presença', (
      tester,
    ) async {
      var confirmed = false;

      await tester.pumpWidget(
        buildTestableWidget(
          AppMeetingResponseButtons(onConfirmPresence: () => confirmed = true),
        ),
      );
      await tester.pumpAndSettle();

      final BuildContext context = tester.element(
        find.byType(AppMeetingResponseButtons),
      );
      final l10n = AppLocalizations.of(context);

      // Clica em confirmar
      await tester.tap(find.text(l10n.groupConfirmMeetingButton));
      await tester.pumpAndSettle();

      expect(confirmed, isTrue);
      expect(find.text(l10n.groupDeclineMeetingButton), findsOneWidget);
      expect(find.text(l10n.groupConfirmMeetingButton), findsNothing);
    });

    testWidgets('Deve alternar para o botão de confirmar ao recusar presença', (
      tester,
    ) async {
      var declined = false;

      await tester.pumpWidget(
        buildTestableWidget(
          AppMeetingResponseButtons(onDeclinePresence: () => declined = true),
        ),
      );
      await tester.pumpAndSettle();

      final BuildContext context = tester.element(
        find.byType(AppMeetingResponseButtons),
      );
      final l10n = AppLocalizations.of(context);

      await tester.tap(find.text(l10n.groupDeclineMeetingButton));
      await tester.pumpAndSettle();

      expect(declined, isTrue);
      expect(find.text(l10n.groupConfirmMeetingButton), findsOneWidget);
      expect(find.text(l10n.groupDeclineMeetingButton), findsNothing);
    });

    testWidgets(
      'Deve permitir alternar a escolha múltiplas vezes consecutivas',
      (tester) async {
        await tester.pumpWidget(
          buildTestableWidget(const AppMeetingResponseButtons()),
        );
        await tester.pumpAndSettle();

        final BuildContext context = tester.element(
          find.byType(AppMeetingResponseButtons),
        );
        final l10n = AppLocalizations.of(context);

        await tester.tap(find.text(l10n.groupConfirmMeetingButton));
        await tester.pumpAndSettle();
        expect(find.text(l10n.groupDeclineMeetingButton), findsOneWidget);

        await tester.tap(find.text(l10n.groupDeclineMeetingButton));
        await tester.pumpAndSettle();
        expect(find.text(l10n.groupConfirmMeetingButton), findsOneWidget);

        await tester.tap(find.text(l10n.groupConfirmMeetingButton));
        await tester.pumpAndSettle();
        expect(find.text(l10n.groupDeclineMeetingButton), findsOneWidget);
      },
    );

    testWidgets('Não deve quebrar quando os callbacks forem nulos', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const AppMeetingResponseButtons(
            onConfirmPresence: null,
            onDeclinePresence: null,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final BuildContext context = tester.element(
        find.byType(AppMeetingResponseButtons),
      );
      final l10n = AppLocalizations.of(context);

      // Garante que o widget trata o ?.call() sem estourar exceção
      await tester.tap(find.text(l10n.groupConfirmMeetingButton));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
