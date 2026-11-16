import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/groups/data/models/group_model.dart';
import 'package:mobile/features/groups/domain/entities/group_entity.dart';
import 'package:mobile/features/groups/domain/entities/group_meeting.dart';
import 'package:mobile/features/groups/domain/entities/group_meeting_status.dart';
import 'package:mobile/features/groups/domain/entities/meeting_invitation_status.dart';

void main() {
  test('maps a group returned by get-my-groups', () {
    final group = GroupModel.fromJson(const {
      'id': 'group-1',
      'number': 1,
      'participant_count': 3,
      'city_state': 'Porto Alegre, RS',
      'photo_url': 'https://example.com/group.jpg',
    });

    expect(
      group.toDomain(),
      const GroupEntity(
        id: 'group-1',
        number: 1,
        participantsCount: 3,
        cityState: 'Porto Alegre, RS',
        photoUrl: 'https://example.com/group.jpg',
      ),
    );
  });

  test('decodes the groups response', () {
    final groups = GroupModel.listFromJson(const {
      'groups': [
        {
          'id': 'group-1',
          'name': 'Group 1',
          'participant_count': 1,
          'city_state': 'Porto Alegre, RS',
          'photo_url': null,
        },
      ],
    });

    expect(groups, hasLength(1));
    expect(groups.single.id, 'group-1');
  });

  test('maps the next meeting and the pending presence response', () {
    final group = GroupModel.fromJson(const {
      'id': 'group-1',
      'number': 1,
      'participant_count': 3,
      'city_state': 'Porto Alegre, RS',
      'photo_url': null,
      'has_pending_response': true,
      'next_meeting': {
        'id': 'meeting-1',
        'host_name': 'Ana',
        'book_title': 'Quarto de Despejo',
        'date': '2026-10-12T19:00:00Z',
        'location': 'Porto Alegre, RS',
      },
    });

    expect(
      group.toDomain().nextMeeting,
      const GroupMeeting(
        id: 'meeting-1',
        hostName: 'Ana',
        bookTitle: 'Quarto de Despejo',
        date: '2026-10-12T19:00:00Z',
        location: 'Porto Alegre, RS',
      ),
    );
    expect(group.hasPendingResponse, isTrue);
  });

  Map<String, dynamic> groupJson({
    Object? invitationStatus,
    bool includeStatus = true,
    Object? meetingStatus,
  }) {
    return {
      'id': 'group-1',
      'number': 1,
      'participant_count': 3,
      'city_state': 'Porto Alegre, RS',
      'photo_url': null,
      'has_pending_response': false,
      'next_meeting': {
        'id': 'meeting-1',
        'host_name': 'Ana',
        'book_title': 'Quarto de Despejo',
        'date': '2026-10-12T19:00:00Z',
        'location': 'Porto Alegre, RS',
        if (includeStatus) 'invitation_status': invitationStatus,
        'status': meetingStatus,
      },
    };
  }

  test('maps invitation_status CONFIRMED from the next meeting', () {
    final group = GroupModel.fromJson(groupJson(invitationStatus: 'CONFIRMED'));

    expect(
      group.toDomain().nextMeeting?.invitationStatus,
      MeetingInvitationStatus.confirmed,
    );
  });

  test('maps invitation_status DECLINED from the next meeting', () {
    final group = GroupModel.fromJson(groupJson(invitationStatus: 'DECLINED'));

    expect(
      group.toDomain().nextMeeting?.invitationStatus,
      MeetingInvitationStatus.declined,
    );
  });

  test('maps invitation_status PENDING from the next meeting', () {
    final group = GroupModel.fromJson(groupJson(invitationStatus: 'PENDING'));

    expect(
      group.toDomain().nextMeeting?.invitationStatus,
      MeetingInvitationStatus.pending,
    );
  });

  test('falls back to pending when invitation_status is missing', () {
    final group = GroupModel.fromJson(groupJson(includeStatus: false));

    expect(
      group.toDomain().nextMeeting?.invitationStatus,
      MeetingInvitationStatus.pending,
    );
  });

  test('falls back to pending when invitation_status is unknown', () {
    final group = GroupModel.fromJson(groupJson(invitationStatus: 'MAYBE'));

    expect(
      group.toDomain().nextMeeting?.invitationStatus,
      MeetingInvitationStatus.pending,
    );
  });

  test('keeps the meeting status when the response was already given', () {
    final group = GroupModel.fromJson(groupJson(invitationStatus: 'CONFIRMED'));

    expect(group.hasPendingResponse, isFalse);
    expect(
      group.toDomain().nextMeeting?.invitationStatus,
      MeetingInvitationStatus.confirmed,
    );
  });

  test('maps can_manage_tasks when present in next_meeting', () {
    final group = GroupModel.fromJson(const {
      'id': 'group-1',
      'number': 1,
      'participant_count': 3,
      'city_state': 'Porto Alegre, RS',
      'photo_url': null,
      'next_meeting': {
        'id': 'meeting-1',
        'host_name': 'Ana',
        'book_title': 'Quarto de Despejo',
        'date': '2026-10-12T19:00:00Z',
        'location': 'Porto Alegre, RS',
        'can_manage_tasks': true,
      },
    });

    expect(group.toDomain().nextMeeting?.canManageTasks, isTrue);
  });

  test(
    'Given status ENDED, When parses, Then maps to GroupMeetingStatus.ended',
    () {
      final group = GroupModel.fromJson(groupJson(meetingStatus: 'ENDED'));

      expect(group.toDomain().nextMeeting?.status, GroupMeetingStatus.ended);
    },
  );

  test('Given status ausente, When parses, Then maps to scheduled', () {
    final group = GroupModel.fromJson(groupJson());

    expect(group.toDomain().nextMeeting?.status, GroupMeetingStatus.scheduled);
  });

  group('pending_meetings', () {
    Map<String, dynamic> pendingMeeting(String id, {String date = ''}) => {
      'id': id,
      'status': 'CREATED',
      'host_name': 'Ana',
      'book_title': 'Quarto de Despejo',
      'date': date,
      'location': '',
      'can_manage_tasks': true,
      'tasks_done': 0,
      'tasks_total': 2,
    };

    test(
      'Given pending_meetings, When parses, Then maps every pending meeting',
      () {
        final group = GroupModel.fromJson({
          ...groupJson(),
          'pending_meetings': [
            pendingMeeting('meeting-old', date: '2026-10-12T19:00:00Z'),
            pendingMeeting('meeting-draft'),
          ],
        });

        final pending = group.toDomain().pendingMeetings;
        expect(pending.map((meeting) => meeting.id), [
          'meeting-old',
          'meeting-draft',
        ]);
        expect(pending.last.date, isEmpty);
        expect(pending.last.canManageTasks, isTrue);
        expect(pending.last.tasksDone, 0);
      },
    );

    test('Given pending_meetings ausente, When parses, Then lista vazia', () {
      final group = GroupModel.fromJson(groupJson());

      expect(group.toDomain().pendingMeetings, isEmpty);
    });

    test('parses pending_raffle inaugural and pending correctly', () {
      final inauguralGroup = GroupModel.fromJson({
        ...groupJson(),
        'pending_raffle': const {
          'type': 'INAUGURAL',
          'group_id': 'g1',
        },
        'has_open_meeting': false,
        'open_meeting_status': null,
      });

      expect(inauguralGroup.pendingRaffle?.type, PendingRaffleType.inaugural);
      expect(
        inauguralGroup.pendingRaffle,
        const PendingRaffle(type: PendingRaffleType.inaugural, groupId: 'g1'),
      );
      expect(inauguralGroup.pendingRaffle?.groupId, 'g1');
      expect(inauguralGroup.pendingRaffle?.meetingId, isNull);
      expect(inauguralGroup.hasOpenMeeting, isFalse);

      final pendingGroup = GroupModel.fromJson({
        ...groupJson(),
        'pending_raffle': const {
          'type': 'PENDING',
          'group_id': 'g1',
          'meeting_id': 'm1',
        },
        'has_open_meeting': true,
        'open_meeting_status': 'CREATED',
      });

      expect(pendingGroup.pendingRaffle?.type, PendingRaffleType.pending);
      expect(pendingGroup.pendingRaffle?.meetingId, 'm1');
      expect(pendingGroup.hasOpenMeeting, isTrue);
      expect(pendingGroup.openMeetingStatus, 'CREATED');

      final copied = pendingGroup.toDomain().copyWith(
            pendingRaffle: const PendingRaffle(
              type: PendingRaffleType.inaugural,
              groupId: 'g2',
            ),
            hasOpenMeeting: false,
            openMeetingStatus: 'SCHEDULED',
          );
      expect(copied.pendingRaffle?.type, PendingRaffleType.inaugural);
      expect(copied.hasOpenMeeting, isFalse);
      expect(copied.openMeetingStatus, 'SCHEDULED');
      expect(copied.props, contains(const PendingRaffle(type: PendingRaffleType.inaugural, groupId: 'g2')));
    });

    test('returns null pending_raffle when invalid or missing group_id', () {
      final groupNull = GroupModel.fromJson({
        ...groupJson(),
        'pending_raffle': null,
      });
      expect(groupNull.pendingRaffle, isNull);

      final groupInvalid = GroupModel.fromJson({
        ...groupJson(),
        'pending_raffle': 'not a map',
      });
      expect(groupInvalid.pendingRaffle, isNull);

      final groupNoId = GroupModel.fromJson({
        ...groupJson(),
        'pending_raffle': const {'type': 'INAUGURAL'},
      });
      expect(groupNoId.pendingRaffle, isNull);
    });

    test(
      'Given item inválido ou nulo em pending_meetings, When parses, Then ignora só o item',
      () {
        final group = GroupModel.fromJson({
          ...groupJson(),
          'pending_meetings': [
            null,
            const {'id': 'meeting-broken', 'host_name': null},
            pendingMeeting('meeting-draft'),
          ],
        });

        expect(group.toDomain().pendingMeetings.map((meeting) => meeting.id), [
          'meeting-draft',
        ]);
      },
    );

    test(
      'Given pending_meetings que não é lista, When parses, Then lista vazia',
      () {
        final group = GroupModel.fromJson({
          ...groupJson(),
          'pending_meetings': const {'id': 'meeting-1'},
        });

        expect(group.toDomain().pendingMeetings, isEmpty);
      },
    );

    test('GroupEntity copyWith and props cover pendingRaffle, hasOpenMeeting, openMeetingStatus', () {
      const entity = GroupEntity(
        id: 'g1',
        number: 1,
        participantsCount: 5,
        cityState: 'POA',
      );
      const raffle = PendingRaffle(type: PendingRaffleType.inaugural, groupId: 'g1');
      final updated = entity.copyWith(
        pendingRaffle: raffle,
        hasOpenMeeting: true,
        openMeetingStatus: 'SCHEDULED',
      );
      expect(updated.pendingRaffle, raffle);
      expect(updated.hasOpenMeeting, isTrue);
      expect(updated.openMeetingStatus, 'SCHEDULED');
      expect(updated.props, contains(raffle));
      expect(updated.props, contains(true));
      expect(updated.props, contains('SCHEDULED'));
    });
  });
}
