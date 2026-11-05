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

  test(
    'Given status CREATED and null date, When parses, Then maps to GroupMeetingStatus.created and empty date',
    () {
      final group = GroupModel.fromJson(const {
        'id': 'group-1',
        'number': 1,
        'participant_count': 3,
        'city_state': 'Porto Alegre, RS',
        'photo_url': null,
        'next_meeting': {
          'id': 'meeting-2',
          'host_name': 'Patrícia',
          'book_title': 'Quarto de Despejo',
          'date': null,
          'location': '',
          'status': 'CREATED',
          'can_manage_tasks': true,
          'tasks_done': 0,
          'tasks_total': 2,
        },
      });

      final meeting = group.toDomain().nextMeeting;
      expect(meeting?.status, GroupMeetingStatus.created);
      expect(meeting?.isCreated, isTrue);
      expect(meeting?.date, isEmpty);
      expect(group.toDomain().pendingMeetings, [meeting]);
    },
  );

  test(
    'Given pending_meetings with multiple meetings, When parses, Then maps all pendingMeetings',
    () {
      final group = GroupModel.fromJson(const {
        'id': 'group-2',
        'number': 2,
        'participant_count': 5,
        'city_state': 'Porto Alegre, RS',
        'photo_url': null,
        'next_meeting': {
          'id': 'meeting-1',
          'host_name': 'Gabriela',
          'book_title': 'O Avesso da Pele',
          'date': '2026-11-02T22:00:00Z',
          'location': 'PUCRS',
          'status': 'ENDED',
          'can_manage_tasks': true,
          'tasks_done': 1,
          'tasks_total': 2,
        },
        'pending_meetings': [
          {
            'id': 'meeting-1',
            'host_name': 'Gabriela',
            'book_title': 'O Avesso da Pele',
            'date': '2026-11-02T22:00:00Z',
            'location': 'PUCRS',
            'status': 'ENDED',
            'can_manage_tasks': true,
            'tasks_done': 1,
            'tasks_total': 2,
          },
          {
            'id': 'meeting-2',
            'host_name': 'Patrícia',
            'book_title': 'Quarto de Despejo',
            'date': '',
            'location': '',
            'status': 'CREATED',
            'can_manage_tasks': true,
            'tasks_done': 0,
            'tasks_total': 2,
          },
        ],
      });

      final pending = group.toDomain().pendingMeetings;
      expect(pending, hasLength(2));
      expect(pending[0].id, 'meeting-1');
      expect(pending[0].status, GroupMeetingStatus.ended);
      expect(pending[1].id, 'meeting-2');
      expect(pending[1].status, GroupMeetingStatus.created);
    },
  );

  test('Given status ausente, When parses, Then maps to scheduled', () {
    final group = GroupModel.fromJson(groupJson());

    expect(group.toDomain().nextMeeting?.status, GroupMeetingStatus.scheduled);
  });
}
