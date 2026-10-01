import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/l10n/app_localizations.dart';

void main() {
  Widget buildSubject(Widget child) => MaterialApp(
    theme: AppTheme.light,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('pt', 'BR'),
    home: Scaffold(
      body: Padding(padding: const EdgeInsets.all(16), child: child),
    ),
  );

  testWidgets('renders event details in two columns', (tester) async {
    await tester.pumpWidget(
      buildSubject(
        GroupNextEvent(
          status: GroupNextEventStatus.loaded,
          data: GroupNextEventData(
            location: 'Porto Alegre, RS',
            date: DateTime(2026, 8, 29),
            hostName: 'Roberta',
          ),
        ),
      ),
    );

    expect(find.text('Porto Alegre, RS'), findsOneWidget);
    expect(find.text('29/08/2026'), findsOneWidget);
    expect(find.text('Anfitriã: Roberta'), findsOneWidget);
    expect(
      tester.widgetList<AppIcon>(find.byType(AppIcon)).map((icon) => icon.icon),
      [AppIcons.location, AppIcons.calendar, AppIcons.user],
    );

    final location = tester.getRect(find.text('Porto Alegre, RS'));
    final date = tester.getRect(find.text('29/08/2026'));
    expect(date.left, greaterThan(location.right));
  });

  testWidgets('renders the empty state with localized text', (tester) async {
    await tester.pumpWidget(
      buildSubject(const GroupNextEvent(status: GroupNextEventStatus.empty)),
    );

    expect(find.text('Nenhum próximo evento agendado'), findsOneWidget);
  });

  testWidgets('renders the generic localized error state', (tester) async {
    await tester.pumpWidget(
      buildSubject(const GroupNextEvent(status: GroupNextEventStatus.error)),
    );

    expect(
      find.text(
        'Ocorreu um erro ao processar sua solicitação. Tente novamente mais tarde.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('renders loading state without throwing', (tester) async {
    await tester.pumpWidget(
      buildSubject(const GroupNextEvent(status: GroupNextEventStatus.loading)),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('does not overflow on a narrow layout', (tester) async {
    tester.view.physicalSize = const Size(320, 400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      buildSubject(
        GroupNextEvent(
          status: GroupNextEventStatus.loaded,
          data: GroupNextEventData(
            location: 'Uma localização muito extensa para a largura disponível',
            date: DateTime(2026, 8, 29),
            hostName: 'Roberta',
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    final location = tester.widget<Text>(
      find.text('Uma localização muito extensa para a largura disponível'),
    );
    expect(location.overflow, isNot(TextOverflow.ellipsis));
    expect(
      tester
          .getSize(
            find.text(
              'Uma localização muito extensa para a largura disponível',
            ),
          )
          .height,
      greaterThan(AppTypographyTokens.standard.bodySmall.fontSize! * 2),
    );
  });

  test('loaded state requires data', () {
    expect(
      () => GroupNextEvent(status: GroupNextEventStatus.loaded),
      throwsAssertionError,
    );
  });

  testWidgets(
    'renders history link with bodyDefaultEmphasis when callback is provided',
    (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        buildSubject(
          GroupNextEvent(
            status: GroupNextEventStatus.loaded,
            data: GroupNextEventData(
              location: 'Porto Alegre, RS',
              date: DateTime(2026, 8, 29),
              hostName: 'Roberta',
            ),
            onEventHistoryPressed: () => tapped = true,
          ),
        ),
      );

      expect(
        find.text('Exibir detalhes dos últimos eventos'),
        findsOneWidget,
      );

      final linkText = tester.widget<Text>(
        find.text('Exibir detalhes dos últimos eventos'),
      );
      expect(
        linkText.style?.fontSize,
        AppTypographyTokens.standard.bodyDefaultEmphasis.fontSize,
      );

      await tester.tap(find.text('Exibir detalhes dos últimos eventos'));
      expect(tapped, isTrue);
    },
  );

  testWidgets('does not render history link when no callback is given', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(
        GroupNextEvent(
          status: GroupNextEventStatus.loaded,
          data: GroupNextEventData(
            location: 'Porto Alegre, RS',
            date: DateTime(2026, 8, 29),
            hostName: 'Roberta',
          ),
        ),
      ),
    );

    expect(find.text('Exibir detalhes dos últimos eventos'), findsNothing);
  });
}
