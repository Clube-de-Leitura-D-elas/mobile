import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/notifications/presentation/widgets/notifications_message_view.dart';
import 'package:mobile/l10n/app_localizations.dart';

void main() {
  const message = 'Nenhuma notificação por aqui';

  Widget buildSubject({VoidCallback? onRetry}) {
    return MaterialApp(
      theme: AppTheme.light,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt', 'BR'),
      home: Scaffold(
        body: NotificationsMessageView(message: message, onRetry: onRetry),
      ),
    );
  }

  testWidgets('uses the body token in the muted color', (tester) async {
    await tester.pumpWidget(buildSubject());

    final context = tester.element(find.text(message));

    expect(
      tester.widget<Text>(find.text(message)).style,
      context.typography.bodyDefault.copyWith(color: context.colors.textMuted),
    );
  });

  testWidgets('announces the message as a live region', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(buildSubject());

    expect(
      tester.getSemantics(find.text(message)),
      isSemantics(label: message, isLiveRegion: true),
    );
    handle.dispose();
  });

  testWidgets('hides the retry without onRetry', (tester) async {
    await tester.pumpWidget(buildSubject());

    expect(find.byType(AppButton), findsNothing);
  });

  testWidgets('offers a retry with a 48px target', (tester) async {
    var retries = 0;
    await tester.pumpWidget(buildSubject(onRetry: () => retries++));

    expect(
      tester.getSize(find.byType(AppButton)).height,
      greaterThanOrEqualTo(48),
    );

    await tester.tap(find.text('Tentar novamente'));

    expect(retries, 1);
  });
}
