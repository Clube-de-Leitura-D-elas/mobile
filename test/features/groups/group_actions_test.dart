import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/presentation/widgets/group_actions.dart';
import 'package:mobile/l10n/app_localizations.dart';

void main() {
  Widget buildSubject(Widget child) => MaterialApp(
    theme: AppTheme.light,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      ...GlobalMaterialLocalizations.delegates,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('pt', 'BR'),
    home: Scaffold(body: child),
  );

  group('GroupActions', () {
    testWidgets(
      'given null whatsappUrl, when rendered, then whatsapp button is disabled',
      (tester) async {
        await tester.pumpWidget(buildSubject(const GroupActions()));

        final button = tester.widget<AppButton>(
          find.widgetWithText(AppButton, 'Abrir Whatsapp'),
        );
        expect(button.onPressed, isNull);

        final recommendButton = tester.widget<AppButton>(
          find.widgetWithText(AppButton, 'Indicar livro'),
        );
        expect(recommendButton.onPressed, isNotNull);
        await tester.tap(find.text('Indicar livro'));
        await tester.pump();
      },
    );

    testWidgets(
      'given empty whatsappUrl, when rendered, then whatsapp button is disabled',
      (tester) async {
        await tester.pumpWidget(
          buildSubject(const GroupActions(whatsappUrl: '   ')),
        );

        final button = tester.widget<AppButton>(
          find.widgetWithText(AppButton, 'Abrir Whatsapp'),
        );
        expect(button.onPressed, isNull);
      },
    );

    testWidgets(
      'given valid whatsappUrl, when button tapped, then calls onOpenWhatsApp with Uri',
      (tester) async {
        Uri? launchedUri;
        await tester.pumpWidget(
          buildSubject(
            GroupActions(
              whatsappUrl: 'https://chat.whatsapp.com/ABC123xyz',
              onOpenWhatsApp: (uri) async {
                launchedUri = uri;
                return true;
              },
            ),
          ),
        );

        final button = tester.widget<AppButton>(
          find.widgetWithText(AppButton, 'Abrir Whatsapp'),
        );
        expect(button.onPressed, isNotNull);

        await tester.tap(find.text('Abrir Whatsapp'));
        await tester.pump();

        expect(launchedUri, Uri.parse('https://chat.whatsapp.com/ABC123xyz'));
      },
    );

    testWidgets(
      'given invalid scheme url, when button tapped, then shows error snackbar',
      (tester) async {
        await tester.pumpWidget(
          buildSubject(const GroupActions(whatsappUrl: 'invalid-url')),
        );

        await tester.tap(find.text('Abrir Whatsapp'));
        await tester.pumpAndSettle();

        expect(
          find.text('Não foi possível abrir o link do WhatsApp.'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'given non-whatsapp https host, when button tapped, then blocks launch and shows error snackbar',
      (tester) async {
        var launched = false;
        await tester.pumpWidget(
          buildSubject(
            GroupActions(
              whatsappUrl: 'https://evil.example.com/phishing',
              onOpenWhatsApp: (_) async {
                launched = true;
                return true;
              },
            ),
          ),
        );

        await tester.tap(find.text('Abrir Whatsapp'));
        await tester.pumpAndSettle();

        expect(launched, isFalse);
        expect(
          find.text('Não foi possível abrir o link do WhatsApp.'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'given launch failure (returns false), when button tapped, then shows error snackbar',
      (tester) async {
        await tester.pumpWidget(
          buildSubject(
            GroupActions(
              whatsappUrl: 'https://chat.whatsapp.com/ABC123xyz',
              onOpenWhatsApp: (uri) async => false,
            ),
          ),
        );

        await tester.tap(find.text('Abrir Whatsapp'));
        await tester.pumpAndSettle();

        expect(
          find.text('Não foi possível abrir o link do WhatsApp.'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'given launch exception, when button tapped, then catches error and shows snackbar',
      (tester) async {
        await tester.pumpWidget(
          buildSubject(
            GroupActions(
              whatsappUrl: 'https://chat.whatsapp.com/ABC123xyz',
              onOpenWhatsApp: (uri) async => throw Exception('Launch failed'),
            ),
          ),
        );

        await tester.tap(find.text('Abrir Whatsapp'));
        await tester.pumpAndSettle();

        expect(
          find.text('Não foi possível abrir o link do WhatsApp.'),
          findsOneWidget,
        );
      },
    );
  });
}
