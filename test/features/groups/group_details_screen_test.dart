import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/presentation/pages/group_details_screen.dart';
import 'package:mobile/l10n/app_localizations.dart';

void main() {
  const group = GroupDetailsScreen(
    name: 'Grupo 1',
    genres: ['Ficção', 'Aventura'],
    participantCount: 34,
    city: 'Porto Alegre',
    stateCode: 'RS',
    nextEventContent: Text('Conteúdo do evento'),
    bookContent: Text('Conteúdo do livro'),
    participantsContent: Text('Conteúdo dos participantes'),
  );

  Widget buildSubject(Widget child) => MaterialApp(
    theme: AppTheme.light.copyWith(splashFactory: NoSplash.splashFactory),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('pt', 'BR'),
    home: child,
  );

  testWidgets('given group data, when opened, then renders the layout shell', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject(group));

    expect(find.text('Grupo 1'), findsOneWidget);
    expect(find.text('Ficção'), findsOneWidget);
    expect(find.text('Aventura'), findsOneWidget);
    expect(find.text('34 participantes'), findsOneWidget);
    expect(find.text('Porto Alegre, RS'), findsOneWidget);
    expect(find.text('Abrir Whatsapp'), findsOneWidget);
    expect(find.text('Indicar livro'), findsOneWidget);
    expect(find.text('Próximo evento'), findsOneWidget);
    expect(find.text('Participantes'), findsOneWidget);
    expect(find.byTooltip('Voltar'), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.text('Conteúdo do evento'), findsOneWidget);
    expect(find.text('Conteúdo do livro'), findsOneWidget);
    expect(find.text('Conteúdo dos participantes'), findsOneWidget);

    final buttons = tester
        .widgetList<AppButton>(find.byType(AppButton))
        .toList();
    expect(buttons.map((button) => button.variant), [
      AppButtonVariant.secondary,
      AppButtonVariant.primary,
    ]);

    final titleBounds = tester.getRect(find.text('Grupo 1'));
    final firstTagBounds = tester.getRect(find.text('Ficção'));
    expect(firstTagBounds.left, greaterThan(titleBounds.right));

    final participantsBounds = tester.getRect(find.text('34 participantes'));
    final locationBounds = tester.getRect(find.text('Porto Alegre, RS'));
    expect(
      locationBounds.left - participantsBounds.right,
      greaterThanOrEqualTo(AppSpacingTokens.standard.s24),
    );

    for (final label in ['Abrir Whatsapp', 'Indicar livro']) {
      final button = find.ancestor(
        of: find.text(label),
        matching: find.byType(AppButton),
      );
      expect(
        tester.getCenter(find.text(label)).dx,
        tester.getCenter(button).dx,
      );
      expect(
        tester.getCenter(find.text(label)).dy,
        tester.getCenter(button).dy,
      );
    }

    final nextEventChevron = find.byKey(
      const ValueKey('section-chevron-Próximo evento'),
    );
    final participantsChevron = find.byKey(
      const ValueKey('section-chevron-Participantes'),
    );
    expect(
      tester.getCenter(nextEventChevron).dx,
      tester.getCenter(participantsChevron).dx,
    );
  });

  testWidgets('given an open group, when back is tapped, then returns home', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(
        Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute<void>(builder: (_) => group)),
              child: const Text('Abrir grupo'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Abrir grupo'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Voltar'));
    await tester.pumpAndSettle();

    expect(find.text('Abrir grupo'), findsOneWidget);
    expect(find.text('Grupo 1'), findsNothing);
  });

  testWidgets(
    'given both sections open, when toggled, then each keeps its state',
    (tester) async {
      await tester.pumpWidget(buildSubject(group));

      final nextEvent = find.byKey(const ValueKey('section-Próximo evento'));
      await tester.ensureVisible(nextEvent);
      await tester.tap(nextEvent);
      await tester.pump();
      expect(find.text('Conteúdo do evento'), findsNothing);
      expect(find.text('Conteúdo do livro'), findsNothing);
      expect(find.text('Conteúdo dos participantes'), findsOneWidget);

      final participants = find.byKey(const ValueKey('section-Participantes'));
      await tester.ensureVisible(participants);
      await tester.tap(participants);
      await tester.pump();
      expect(find.text('Conteúdo dos participantes'), findsNothing);

      await tester.ensureVisible(nextEvent);
      await tester.tap(nextEvent);
      await tester.pump();
      expect(find.text('Conteúdo do evento'), findsOneWidget);
      expect(find.text('Conteúdo do livro'), findsOneWidget);
      expect(find.text('Conteúdo dos participantes'), findsNothing);
    },
  );

  testWidgets(
    'given narrow width and many genres, when rendered, then no overflow',
    (tester) async {
      tester.view.physicalSize = const Size(320, 700);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        buildSubject(
          const GroupDetailsScreen(
            name: 'Clube de leitura com um nome muito comprido para a tela',
            genres: ['Ficção', 'Aventura', 'Romance', 'Suspense', 'Fantasia'],
            participantCount: 34,
            city:
                'Cidade com um nome muito comprido que precisa quebrar a linha',
            stateCode: 'RS',
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Fantasia'), findsOneWidget);
      expect(find.text('Abrir Whatsapp'), findsOneWidget);
      expect(find.text('Indicar livro'), findsOneWidget);

      final nameBounds = tester.getRect(find.byKey(const ValueKey('group-name')));
      final genresBounds = tester.getRect(
        find.byKey(const ValueKey('group-genres')),
      );
      expect(genresBounds.top, greaterThanOrEqualTo(nameBounds.bottom));
    },
  );

  testWidgets('given action buttons, when tapped, then the page stays open', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject(group));

    await tester.tap(find.text('Abrir Whatsapp'));
    await tester.tap(find.text('Indicar livro'));
    await tester.pump();

    expect(find.text('Grupo 1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
