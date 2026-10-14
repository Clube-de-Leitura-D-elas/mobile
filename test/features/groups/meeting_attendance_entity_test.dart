import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/groups/domain/entities/meeting_attendance_entity.dart';
import 'package:mobile/features/groups/domain/entities/meeting_invitation_status.dart';
import 'package:mobile/features/groups/domain/entities/meeting_presence_status.dart';

void main() {
  group('MeetingAttendanceEntity', () {
    const participant1 = MeetingAttendanceEntity(
      id: 'user-1',
      name: 'Ana Souza',
      photoUrl: 'https://example.com/photo.jpg',
      invitationStatus: MeetingInvitationStatus.confirmed,
      presenceStatus: MeetingPresenceStatus.present,
    );

    const participant2 = MeetingAttendanceEntity(
      id: 'user-1',
      name: 'Ana Souza',
      photoUrl: 'https://example.com/photo.jpg',
      invitationStatus: MeetingInvitationStatus.confirmed,
      presenceStatus: MeetingPresenceStatus.present,
    );

    const participantDifferent = MeetingAttendanceEntity(
      id: 'user-2',
      name: 'Carlos Silva',
      photoUrl: null,
      invitationStatus: MeetingInvitationStatus.pending,
      presenceStatus: null,
    );

    test(
      'deve considerar duas instâncias com os mesmos valores como iguais',
      () {
        expect(participant1, equals(participant2));
      },
    );

    test(
      'deve considerar instâncias com valores diferentes como não iguais',
      () {
        expect(participant1, isNot(equals(participantDifferent)));
      },
    );

    test('props deve conter todas as propriedades da entidade', () {
      expect(participant1.props, [
        'user-1',
        'Ana Souza',
        'https://example.com/photo.jpg',
        MeetingInvitationStatus.confirmed,
        MeetingPresenceStatus.present,
      ]);
    });
  });
}
