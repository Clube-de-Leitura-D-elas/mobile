import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/domain/entities/meeting_attendance_entity.dart';
import 'package:mobile/features/groups/domain/entities/meeting_invitation_status.dart';
import 'package:mobile/features/groups/domain/entities/meeting_presence_status.dart';
import 'package:mobile/features/groups/presentation/widgets/app_participant_attendance_card.dart';
import 'package:mobile/features/groups/presentation/widgets/app_participant_avatar.dart';

void main() {
  Widget createWidget(MeetingAttendanceEntity participant) {
    return MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: AppParticipantAttendanceCard(participant: participant),
      ),
    );
  }

  group('AppParticipantAttendanceCard', () {
    testWidgets('exibe nome, avatar e status do participante', (tester) async {
      await tester.pumpWidget(
        createWidget(
          const MeetingAttendanceEntity(
            id: 'user-1',
            name: 'Ana Souza',
            photoUrl: null,
            invitationStatus: MeetingInvitationStatus.confirmed,
            presenceStatus: MeetingPresenceStatus.present,
          ),
        ),
      );

      expect(find.text('Ana Souza'), findsOneWidget);
      expect(find.byType(AppParticipantAvatar), findsOneWidget);
      expect(find.text('Confirmada'), findsOneWidget);
      expect(find.text('Presente'), findsOneWidget);
    });

    testWidgets('exibe status de convite recusado e presença ausente', (
      tester,
    ) async {
      await tester.pumpWidget(
        createWidget(
          const MeetingAttendanceEntity(
            id: 'user-2',
            name: 'Maria Silva',
            photoUrl: null,
            invitationStatus: MeetingInvitationStatus.declined,
            presenceStatus: MeetingPresenceStatus.absent,
          ),
        ),
      );

      expect(find.text('Maria Silva'), findsOneWidget);
      expect(find.text('Recusou'), findsOneWidget);
      expect(find.text('Ausente'), findsOneWidget);
    });

    testWidgets('exibe Sem resposta quando o convite está pendente', (
      tester,
    ) async {
      await tester.pumpWidget(
        createWidget(
          const MeetingAttendanceEntity(
            id: 'user-3',
            name: 'Carla Oliveira',
            photoUrl: null,
            invitationStatus: MeetingInvitationStatus.pending,
            presenceStatus: null,
          ),
        ),
      );

      expect(find.text('Carla Oliveira'), findsOneWidget);
      expect(find.text('Sem resposta'), findsOneWidget);
    });

    testWidgets('exibe Não registrada quando a presença é null', (
      tester,
    ) async {
      await tester.pumpWidget(
        createWidget(
          const MeetingAttendanceEntity(
            id: 'user-4',
            name: 'Julia Santos',
            photoUrl: null,
            invitationStatus: MeetingInvitationStatus.confirmed,
            presenceStatus: null,
          ),
        ),
      );

      expect(find.text('Confirmada'), findsOneWidget);
      expect(find.text('Não registrada'), findsOneWidget);
      expect(find.text('Ausente'), findsNothing);
    });

    testWidgets('usa o avatar padrão quando não há foto', (tester) async {
      await tester.pumpWidget(
        createWidget(
          const MeetingAttendanceEntity(
            id: 'user-5',
            name: 'Beatriz Lima',
            photoUrl: null,
            invitationStatus: MeetingInvitationStatus.pending,
            presenceStatus: null,
          ),
        ),
      );

      expect(find.byType(AppParticipantAvatar), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
    });
  });
}
