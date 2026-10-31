import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/l10n/app_localizations.dart';

Future<void> _openDialog(
  WidgetTester tester,
  AppDialog dialog, {
  bool localized = false,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      locale: localized ? const Locale('pt') : null,
      localizationsDelegates: localized
          ? AppLocalizations.localizationsDelegates
          : null,
      supportedLocales: localized
          ? AppLocalizations.supportedLocales
          : const [Locale('en', 'US')],
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () =>
                showDialog<void>(context: context, builder: (_) => dialog),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  group('AppDialog', () {
    testWidgets('Renders the title and the child content', (tester) async {
      await _openDialog(
        tester,
        const AppDialog(title: 'Avaliar livro', child: Text('conteúdo')),
      );

      expect(find.text('Avaliar livro'), findsOneWidget);
      expect(find.text('conteúdo'), findsOneWidget);
    });

    testWidgets('Uses the headingH3 token in textDefault for the title', (
      tester,
    ) async {
      await _openDialog(
        tester,
        const AppDialog(title: 'Avaliar livro', child: SizedBox()),
      );

      final text = tester.widget<Text>(find.text('Avaliar livro'));

      expect(
        text.style?.fontSize,
        AppTypographyTokens.standard.headingH3.fontSize,
      );
      expect(
        text.style?.fontWeight,
        AppTypographyTokens.standard.headingH3.fontWeight,
      );
      expect(text.style?.color, AppColorTokens.light.textDefault);
    });

    testWidgets('Uses a 16 corner radius and the bgDefault background', (
      tester,
    ) async {
      await _openDialog(
        tester,
        const AppDialog(title: 'Título', child: SizedBox()),
      );

      final dialog = tester.widget<Dialog>(find.byType(Dialog));
      final shape = dialog.shape as RoundedRectangleBorder;

      expect(shape.borderRadius, BorderRadius.circular(16.0));
      expect(dialog.backgroundColor, AppColorTokens.light.bgDefault);
    });

    testWidgets('Closes the dialog when the close button is tapped', (
      tester,
    ) async {
      await _openDialog(
        tester,
        const AppDialog(title: 'Título', child: SizedBox()),
      );

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.byType(AppDialog), findsNothing);
    });

    testWidgets('Calls onClose instead of popping when provided', (
      tester,
    ) async {
      var closed = 0;
      await _openDialog(
        tester,
        AppDialog(
          title: 'Título',
          onClose: () => closed++,
          child: const SizedBox(),
        ),
      );

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(closed, 1);
      expect(find.byType(AppDialog), findsOneWidget);
    });

    testWidgets('Uses the localized close label for the close tooltip', (
      tester,
    ) async {
      await _openDialog(
        tester,
        const AppDialog(title: 'Título', child: SizedBox()),
        localized: true,
      );

      final context = tester.element(find.byType(AppDialog));

      expect(
        find.byTooltip(AppLocalizations.of(context).close),
        findsOneWidget,
      );
    });

    testWidgets('Exposes the close button with the "Fechar" tooltip', (
      tester,
    ) async {
      await _openDialog(
        tester,
        const AppDialog(title: 'Título', child: SizedBox()),
      );

      expect(find.byTooltip('Fechar'), findsOneWidget);
      expect(
        tester.getSize(
          find
              .ancestor(
                of: find.byType(IconButton),
                matching: find.byType(SizedBox),
              )
              .first,
        ),
        const Size(48, 48),
      );
    });

    testWidgets('Marks the title as a header that names the dialog route', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await _openDialog(
        tester,
        const AppDialog(title: 'Título', child: SizedBox()),
      );

      expect(
        tester.getSemantics(find.text('Título')),
        matchesSemantics(label: 'Título', isHeader: true, namesRoute: true),
      );
      handle.dispose();
    });

    testWidgets(
      'Does not name the route on iOS to avoid a duplicate announcement',
      (tester) async {
        final handle = tester.ensureSemantics();
        await _openDialog(
          tester,
          const AppDialog(title: 'Título', child: SizedBox()),
        );

        expect(
          tester.getSemantics(find.text('Título')),
          matchesSemantics(label: 'Título', isHeader: true),
        );
        handle.dispose();
      },
      variant: TargetPlatformVariant.only(TargetPlatform.iOS),
    );

    testWidgets('Does not render the actions row without actions', (
      tester,
    ) async {
      await _openDialog(
        tester,
        const AppDialog(title: 'Título', child: SizedBox()),
      );

      expect(find.byType(AppButton), findsNothing);
      expect(find.byType(Gap24), findsNothing);
    });

    testWidgets('Splits the width equally between the actions', (tester) async {
      await _openDialog(
        tester,
        AppDialog(
          title: 'Título',
          actions: [
            AppButton.secondary(label: 'Cancelar', onPressed: () {}),
            AppButton.primary(label: 'Concluir', onPressed: () {}),
          ],
          child: const SizedBox(),
        ),
      );

      final cancel = tester.getRect(find.byType(AppButton).at(0));
      final confirm = tester.getRect(find.byType(AppButton).at(1));

      expect(cancel.width, confirm.width);
      expect(confirm.left - cancel.right, AppSpacingTokens.standard.s16);
    });

    testWidgets('Scrolls the child content when it exceeds the screen', (
      tester,
    ) async {
      await _openDialog(
        tester,
        const AppDialog(title: 'Título', child: SizedBox(height: 2000)),
      );

      expect(tester.takeException(), isNull);
      expect(
        find.descendant(
          of: find.byType(AppDialog),
          matching: find.byType(SingleChildScrollView),
        ),
        findsOneWidget,
      );
    });
  });
}
