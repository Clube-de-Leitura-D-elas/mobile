import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/auth/presentation/widgets/google_sign_in_button.dart';
import 'package:mobile/l10n/app_localizations.dart';

void main() {
  Widget buildWidget(Widget child) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.light,
      home: Scaffold(body: child),
    );
  }

  group('GoogleSignInButton Widget', () {
    testWidgets('renders button text and icon when not loading', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          GoogleSignInButton(
            onPressed: () {},
          ),
        ),
      );

      expect(find.text('Entrar com Google'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('renders CircularProgressIndicator when isLoading is true', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          GoogleSignInButton(
            onPressed: () {},
            isLoading: true,
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('triggers onPressed callback when tapped', (tester) async {
      bool pressed = false;
      await tester.pumpWidget(
        buildWidget(
          GoogleSignInButton(
            onPressed: () => pressed = true,
          ),
        ),
      );

      await tester.tap(find.byType(GoogleSignInButton));
      await tester.pump();

      expect(pressed, isTrue);
    });
  });
}
