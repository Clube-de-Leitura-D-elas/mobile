import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/domain/entities/meeting_attendance_entity.dart';
import 'package:mobile/features/groups/domain/entities/meeting_invitation_status.dart';
import 'package:mobile/features/groups/domain/entities/meeting_presence_status.dart';
import 'package:mobile/features/groups/presentation/pages/meeting_attendance_screen.dart';
import 'package:mobile/features/groups/presentation/widgets/app_participant_attendance_card.dart';
import 'package:mobile/l10n/app_localizations.dart';

void main() {
  const participant = MeetingAttendanceEntity(
    id: 'user-1',
    name: 'Ana Souza',
    photoUrl: null,
    invitationStatus: MeetingInvitationStatus.confirmed,
    presenceStatus: MeetingPresenceStatus.present,
  );

  Widget createWidget({List<MeetingAttendanceEntity> participants = const []}) {
    return MaterialApp(
      theme: AppTheme.light,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: MeetingAttendanceScreen(
        meetingName: 'Encontro de leitura',
        formattedDate: '12/10/2026 às 19:00',
        participants: participants,
      ),
    );
  }

  group('MeetingAttendanceScreen', () {
    testWidgets('exibe o nome do encontro e a data', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.text('Encontro de leitura'), findsWidgets);
      expect(find.text('12/10/2026 às 19:00'), findsOneWidget);
    });

    testWidgets('exibe mensagem quando não há participantes', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.text('Nenhuma participante no grupo.'), findsOneWidget);
      expect(find.byType(AppParticipantAttendanceCard), findsNothing);
    });

    testWidgets('exibe um card para cada participante', (tester) async {
      await tester.pumpWidget(
        createWidget(
          participants: const [
            participant,
            MeetingAttendanceEntity(
              id: 'user-2',
              name: 'Maria Silva',
              photoUrl: null,
              invitationStatus: MeetingInvitationStatus.pending,
              presenceStatus: null,
            ),
          ],
        ),
      );

      expect(find.byType(AppParticipantAttendanceCard), findsNWidgets(2));
      expect(find.text('Ana Souza'), findsOneWidget);
      expect(find.text('Maria Silva'), findsOneWidget);
      expect(find.text('Nenhuma participante no grupo.'), findsNothing);
    });

    testWidgets('exibe o card mesmo sem presença registrada', (tester) async {
      await tester.pumpWidget(
        createWidget(
          participants: const [
            MeetingAttendanceEntity(
              id: 'user-2',
              name: 'Maria Silva',
              photoUrl: null,
              invitationStatus: MeetingInvitationStatus.pending,
              presenceStatus: null,
            ),
          ],
        ),
      );

      expect(find.text('Maria Silva'), findsOneWidget);
      expect(find.text('Não registrada'), findsOneWidget);
    });
  });
}
