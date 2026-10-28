import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/domain/entities/meeting_attendance_entity.dart';
import 'package:mobile/features/groups/domain/entities/meeting_invitation_status.dart';
import 'package:mobile/features/groups/domain/entities/meeting_presence_status.dart';
import 'package:mobile/features/groups/presentation/widgets/meeting_presence_attendee_tile.dart';
import 'package:mobile/l10n/app_localizations.dart';

MeetingAttendanceEntity _attendee({
  String name = 'Ana',
  MeetingInvitationStatus status = MeetingInvitationStatus.confirmed,
}) => MeetingAttendanceEntity(
  id: 'u-1',
  name: name,
  invitationStatus: status,
  presenceStatus: MeetingPresenceStatus.present,
);

void main() {
  Future<void> pumpTile(
    WidgetTester tester, {
    required MeetingAttendanceEntity attendee,
    bool isChecked = false,
    VoidCallback? onChanged,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('pt', 'BR'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Scaffold(
          body: PresenceAttendeeTile(
            attendee: attendee,
            isChecked: isChecked,
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  AppLocalizations l10nOf(WidgetTester tester) =>
      AppLocalizations.of(tester.element(find.byType(PresenceAttendeeTile)));

  group('PresenceAttendeeTile', () {
    testWidgets('mostra o nome e o status confirmado', (tester) async {
      await pumpTile(tester, attendee: _attendee(), onChanged: () {});

      expect(find.text('Ana'), findsOneWidget);
      expect(find.text(l10nOf(tester).invitationConfirmed), findsOneWidget);
    });

    testWidgets('mostra o status sem resposta quando pendente', (tester) async {
      await pumpTile(
        tester,
        attendee: _attendee(status: MeetingInvitationStatus.pending),
        onChanged: () {},
      );

      expect(find.text(l10nOf(tester).invitationNoResponse), findsOneWidget);
    });

    testWidgets('mostra o status recusado', (tester) async {
      await pumpTile(
        tester,
        attendee: _attendee(status: MeetingInvitationStatus.declined),
        onChanged: () {},
      );

      expect(find.text(l10nOf(tester).invitationDeclined), findsOneWidget);
    });

    testWidgets('o checkbox reflete isChecked', (tester) async {
      await pumpTile(
        tester,
        attendee: _attendee(),
        isChecked: true,
        onChanged: () {},
      );
      expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);

      await pumpTile(
        tester,
        attendee: _attendee(),
        isChecked: false,
        onChanged: () {},
      );
      expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isFalse);
    });

    testWidgets('tocar no tile dispara onChanged', (tester) async {
      var calls = 0;
      await pumpTile(tester, attendee: _attendee(), onChanged: () => calls++);

      await tester.tap(find.byType(ListTile));

      expect(calls, 1);
    });

    testWidgets('tocar no checkbox dispara onChanged', (tester) async {
      var calls = 0;
      await pumpTile(tester, attendee: _attendee(), onChanged: () => calls++);

      await tester.tap(find.byType(Checkbox));

      expect(calls, 1);
    });

    testWidgets('sem onChanged o checkbox fica desabilitado', (tester) async {
      await pumpTile(tester, attendee: _attendee(), onChanged: null);

      expect(tester.widget<Checkbox>(find.byType(Checkbox)).onChanged, isNull);
      expect(tester.widget<ListTile>(find.byType(ListTile)).onTap, isNull);

      await tester.tap(find.byType(ListTile));
      expect(tester.takeException(), isNull);
    });

    testWidgets('nome vazio não gera exceção', (tester) async {
      await pumpTile(
        tester,
        attendee: _attendee(name: ''),
        onChanged: () {},
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(PresenceAttendeeTile), findsOneWidget);
    });
  });
}
