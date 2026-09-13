import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/design_system/widgets/screen_header.dart';

void main() {
  group('ScreenHeader', () {
    testWidgets('Simple variant renders the given title', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(appBar: ScreenHeader.simple(title: 'Início')),
        ),
      );

      expect(find.text('Início'), findsOneWidget);
    });

    testWidgets('Simple variant does not show a back button or action slot', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(appBar: ScreenHeader.simple(title: 'Início')),
        ),
      );

      expect(find.byType(IconButton), findsNothing);
    });

    testWidgets('Back variant shows a back button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            appBar: ScreenHeader.back(title: 'Detalhe', onBackPressed: () {}),
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('Back variant triggers onBackPressed when provided', (
      tester,
    ) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            appBar: ScreenHeader.back(
              title: 'Detalhe',
              onBackPressed: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets(
      'Back variant pops the navigator when onBackPressed is not provided',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const Scaffold(
                        appBar: ScreenHeader.back(title: 'Detalhe'),
                      ),
                    ),
                  ),
                  child: const Text('Abrir detalhe'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Abrir detalhe'));
        await tester.pumpAndSettle();

        expect(find.text('Detalhe'), findsOneWidget);

        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();

        expect(find.text('Detalhe'), findsNothing);
        expect(find.text('Abrir detalhe'), findsOneWidget);
      },
    );

    testWidgets('Action variant renders the given action widget', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            appBar: ScreenHeader.action(
              title: 'Meu clube',
              action: IconButton(
                icon: const Icon(Icons.notifications_none),
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Meu clube'), findsOneWidget);
      expect(find.byIcon(Icons.notifications_none), findsOneWidget);
    });

    testWidgets('Action variant triggers the action widget onPressed', (
      tester,
    ) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            appBar: ScreenHeader.action(
              title: 'Meu clube',
              action: IconButton(
                icon: const Icon(Icons.notifications_none),
                onPressed: () => tapped = true,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.notifications_none));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('Uses a 56 height regardless of variant', (tester) async {
      expect(
        const ScreenHeader.simple(title: 'Início').preferredSize,
        const Size.fromHeight(56),
      );
      expect(
        const ScreenHeader.back(title: 'Detalhe').preferredSize,
        const Size.fromHeight(56),
      );
      expect(
        ScreenHeader.action(
          title: 'Meu clube',
          action: IconButton(icon: const Icon(Icons.add), onPressed: () {}),
        ).preferredSize,
        const Size.fromHeight(56),
      );
    });

    testWidgets('Renders the title with headingH3 style and default color', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(appBar: ScreenHeader.simple(title: 'Início')),
        ),
      );

      final titleText = tester.widget<Text>(find.text('Início'));

      expect(
        titleText.style?.fontSize,
        AppTypographyTokens.standard.headingH3.fontSize,
      );
      expect(
        titleText.style?.fontWeight,
        AppTypographyTokens.standard.headingH3.fontWeight,
      );
      expect(titleText.style?.color, AppColorTokens.light.textDefault);
    });

    testWidgets('Uses bgDefault as the background color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(appBar: ScreenHeader.simple(title: 'Início')),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));

      expect(container.color, AppColorTokens.light.bgDefault);
    });
  });
}
