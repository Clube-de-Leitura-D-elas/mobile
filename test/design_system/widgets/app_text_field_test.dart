import 'package:cupertino_ui/cupertino_ui.dart'
    show GlobalCupertinoLocalizations;
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/l10n/app_localizations.dart';

void main() {
  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      theme: AppTheme.light,
      locale: const Locale('pt', 'BR'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(body: child),
    );
  }

  group('AppTextField Widget', () {
    testWidgets('renders label and hintText correctly', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const AppTextField(
            label: 'E-mail',
            hintText: 'seu@email.com',
          ),
        ),
      );

      expect(find.text('E-mail'), findsOneWidget);
      expect(find.text('seu@email.com'), findsOneWidget);
    });

    testWidgets('displays errorText when provided', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const AppTextField(
            label: 'E-mail',
            errorText: 'Campo obrigatório',
          ),
        ),
      );

      expect(find.text('Campo obrigatório'), findsOneWidget);
    });

    testWidgets('toggles obscure text visibility when eye suffix icon is tapped', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const AppTextField(
            label: 'Senha',
            obscureText: true,
          ),
        ),
      );

      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
      expect(find.byTooltip('Mostrar senha'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();

      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
      expect(find.byTooltip('Ocultar senha'), findsOneWidget);
    });

    testWidgets('applies the given input formatters', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        buildTestableWidget(
          AppTextField(
            controller: controller,
            inputFormatters: const [DateInputFormatter()],
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), '12032026');

      expect(controller.text, '12/03/2026');
    });

    testWidgets('renders red asterisk when isRequired is true', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const AppTextField(
            label: 'Data',
            isRequired: true,
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.byType(Text).first);
      expect(textWidget.textSpan, isNotNull);
      final textSpan = textWidget.textSpan as TextSpan;
      expect(textSpan.text, 'Data');
      expect(textSpan.children, isNotEmpty);
      final asteriskSpan = textSpan.children!.first as TextSpan;
      expect(asteriskSpan.text, ' *');
      expect(asteriskSpan.style?.color, const Color(0xFFD92D20));
    });
  });
}
