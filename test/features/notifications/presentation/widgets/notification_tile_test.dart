import 'package:cupertino_ui/cupertino_ui.dart'
    show GlobalCupertinoLocalizations;
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/notifications/domain/entities/notification_entity.dart';
import 'package:mobile/features/notifications/domain/entities/notification_type.dart';
import 'package:mobile/features/notifications/presentation/widgets/notification_tile.dart';
import 'package:mobile/l10n/app_localizations.dart';

void main() {
  const unreadDot = Key('notification-unread-dot');

  Widget buildSubject({required bool isRead, VoidCallback? onTap}) {
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
        body: NotificationTile(
          notification: NotificationEntity(
            id: 'n1',
            title: 'Título',
            message: 'Mensagem',
            type: NotificationType.meetingReminder,
            date: DateTime.now().subtract(const Duration(hours: 2)),
            isRead: isRead,
          ),
          onTap: onTap ?? () {},
        ),
      ),
    );
  }

  testWidgets('highlights an unread notification', (tester) async {
    await tester.pumpWidget(buildSubject(isRead: false));

    final context = tester.element(find.byType(NotificationTile));
    final title = tester.widget<Text>(find.text('Título'));

    expect(find.byKey(unreadDot), findsOneWidget);
    expect(
      title.style?.fontWeight,
      context.typography.bodyDefaultEmphasis.fontWeight,
    );
    expect(
      tester.widget<AppIcon>(find.byType(AppIcon)).color,
      context.colors.textBrand,
    );
  });

  testWidgets('keeps a read notification neutral', (tester) async {
    await tester.pumpWidget(buildSubject(isRead: true));

    final context = tester.element(find.byType(NotificationTile));
    final title = tester.widget<Text>(find.text('Título'));

    expect(find.byKey(unreadDot), findsNothing);
    expect(title.style?.fontWeight, context.typography.bodyDefault.fontWeight);
    expect(
      tester.widget<AppIcon>(find.byType(AppIcon)).color,
      context.colors.textMuted,
    );
  });

  testWidgets('renders the card without the border that toggles on tap', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject(isRead: false));

    expect(tester.widget<AppCard>(find.byType(AppCard)).showBorder, isFalse);
  });

  testWidgets('calls onTap when pressed', (tester) async {
    var taps = 0;
    await tester.pumpWidget(buildSubject(isRead: false, onTap: () => taps++));

    await tester.tap(find.byType(NotificationTile));

    expect(taps, 1);
  });

  testWidgets('announces the unread state, content and date', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(buildSubject(isRead: false));

    expect(
      tester.getSemantics(find.byType(NotificationTile)),
      isSemantics(
        label: 'Não lida: Título. Mensagem',
        value: 'há 2 h',
        isButton: true,
        hasTapAction: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('drops the unread prefix once read', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(buildSubject(isRead: true));

    expect(
      tester.getSemantics(find.byType(NotificationTile)),
      isSemantics(label: 'Título. Mensagem', value: 'há 2 h'),
    );
    handle.dispose();
  });
}
