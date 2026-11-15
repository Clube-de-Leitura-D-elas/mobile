import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/calendar/data/models/calendar_meeting_model.dart';
import 'package:mobile/features/calendar/domain/entities/calendar_group_entity.dart';
import 'package:mobile/features/calendar/domain/entities/calendar_guest_status.dart';
import 'package:mobile/features/calendar/domain/entities/calendar_meeting_entity.dart';
import 'package:mobile/features/calendar/domain/entities/calendar_meeting_status.dart';
import 'package:mobile/features/calendar/domain/entities/calendar_membership_status.dart';

Map<String, dynamic> _memberJson() => {
  'id': 'm1',
  'date': '2026-11-24T22:00:00+00:00',
  'local_date': '2026-11-24',
  'status': 'SCHEDULED',
  'location': {
    'name': 'Café Central',
    'address': 'Rua A, 10',
    'neighborhood': 'Centro',
  },
  'host_name': 'Gabriela',
  'group': {
    'id': 'g1',
    'number': 5,
    'city_state': 'Porto Alegre, RS',
    'photo_url': 'https://example.com/g1.png',
    'participant_count': 27,
    'membership_status': 'MEMBER',
  },
};

Map<String, dynamic> _nonMemberJson({
  Object? membershipStatus,
  Object? status = 'CREATED',
  Object? cityState = 'Porto Alegre, RS',
  Map<String, dynamic>? location = const {
    'name': null,
    'address': null,
    'neighborhood': 'Moinhos',
  },
}) => {
  'id': 'm2',
  'date': '2026-11-25T01:30:00+00:00',
  'local_date': '2026-11-24',
  'status': status,
  'location': location,
  'host_name': null,
  'group': {
    'id': 'g2',
    'number': 7,
    'city_state': cityState,
    'photo_url': null,
    'participant_count': 3,
    'membership_status': membershipStatus,
  },
};

void main() {
  group('CalendarMeetingModel', () {
    test('parses a meeting of a group the user is a member of', () {
      final entity = CalendarMeetingModel.fromJson(_memberJson()).toDomain();

      expect(
        entity,
        CalendarMeetingEntity(
          id: 'm1',
          date: DateTime.utc(2026, 11, 24, 22),
          localDate: DateTime(2026, 11, 24),
          status: CalendarMeetingStatus.scheduled,
          locationName: 'Café Central',
          locationAddress: 'Rua A, 10',
          neighborhood: 'Centro',
          hostName: 'Gabriela',
          group: const CalendarGroupEntity(
            id: 'g1',
            number: 5,
            cityState: 'Porto Alegre, RS',
            photoUrl: 'https://example.com/g1.png',
            participantCount: 27,
            membershipStatus: CalendarMembershipStatus.member,
          ),
        ),
      );
      expect(entity.placeLabel, 'Café Central');
    });

    test('keeps the civil local_date even when the UTC date is the next '
        'day', () {
      final entity = CalendarMeetingModel.fromJson(_nonMemberJson()).toDomain();

      expect(entity.date, DateTime.utc(2026, 11, 25, 1, 30));
      expect(entity.localDate, DateTime(2026, 11, 24));
    });

    test('parses the null fields a non-member receives', () {
      final entity = CalendarMeetingModel.fromJson(_nonMemberJson()).toDomain();

      expect(entity.locationName, isNull);
      expect(entity.locationAddress, isNull);
      expect(entity.hostName, isNull);
      expect(entity.group.photoUrl, isNull);
      expect(entity.group.membershipStatus, CalendarMembershipStatus.none);
      expect(entity.group.isMember, isFalse);
      expect(entity.placeLabel, 'Moinhos');
    });

    test('has no place when the location and the city are empty', () {
      final entity = CalendarMeetingModel.fromJson(
        _nonMemberJson(
          location: const {'name': '', 'address': null, 'neighborhood': ' '},
          cityState: '',
        ),
      ).toDomain();

      expect(entity.placeLabel, isNull);
    });

    final meetingStatuses = <Object?, CalendarMeetingStatus>{
      'CREATED': CalendarMeetingStatus.created,
      'SCHEDULED': CalendarMeetingStatus.scheduled,
      'IN_PROGRESS': CalendarMeetingStatus.inProgress,
      'ENDED': CalendarMeetingStatus.ended,
      'CONCLUDED': CalendarMeetingStatus.concluded,
      'SOMETHING_NEW': CalendarMeetingStatus.unknown,
      null: CalendarMeetingStatus.unknown,
    };
    for (final MapEntry(key: raw, value: status) in meetingStatuses.entries) {
      test('maps status $raw', () {
        final entity = CalendarMeetingModel.fromJson(
          _nonMemberJson(status: raw),
        ).toDomain();

        expect(entity.status, status);
      });
    }

    test('falls back to the city when there is no location at all', () {
      final entity = CalendarMeetingModel.fromJson(
        _nonMemberJson(location: null),
      ).toDomain();

      expect(entity.neighborhood, isNull);
      expect(entity.placeLabel, 'Porto Alegre, RS');
    });

    final statuses = <String, CalendarMembershipStatus>{
      'MEMBER': CalendarMembershipStatus.member,
      'REQUESTED': CalendarMembershipStatus.requested,
      'REJECTED': CalendarMembershipStatus.rejected,
      'PENDING': CalendarMembershipStatus.pending,
      'SOMETHING_NEW': CalendarMembershipStatus.none,
    };
    for (final MapEntry(key: raw, value: status) in statuses.entries) {
      test('maps membership_status $raw', () {
        final entity = CalendarMeetingModel.fromJson(
          _nonMemberJson(membershipStatus: raw),
        ).toDomain();

        expect(entity.group.membershipStatus, status);
      });
    }

    test('has no guest_status for a member or a response without it', () {
      expect(
        CalendarMeetingModel.fromJson(_memberJson()).toDomain().guestStatus,
        isNull,
      );
      expect(
        CalendarMeetingModel.fromJson({
          ..._nonMemberJson(),
          'guest_status': null,
        }).toDomain().guestStatus,
        isNull,
      );
    });

    final guestStatuses = <String, CalendarGuestStatus>{
      'REQUESTED': CalendarGuestStatus.requested,
      'ACCEPTED': CalendarGuestStatus.accepted,
      'REJECTED': CalendarGuestStatus.rejected,
      // Status novo não pode virar "sem pedido", que oferece pedir de novo.
      'SOMETHING_NEW': CalendarGuestStatus.unknown,
    };
    for (final MapEntry(key: raw, value: status) in guestStatuses.entries) {
      test('maps guest_status $raw', () {
        final entity = CalendarMeetingModel.fromJson({
          ..._nonMemberJson(),
          'guest_status': raw,
        }).toDomain();

        expect(entity.guestStatus, status);
      });
    }

    test('reads can_request_participation; a missing field does not offer '
        'the request', () {
      bool canRequest(Object? value) => CalendarMeetingModel.fromJson({
        ..._nonMemberJson(),
        'can_request_participation': ?value,
      }).toDomain().canRequestParticipation;

      expect(canRequest(true), isTrue);
      expect(canRequest(false), isFalse);
      expect(canRequest(null), isFalse);
      expect(canRequest('true'), isFalse);
    });

    test('reads the meetings list of the response body', () {
      final models = CalendarMeetingModel.listFromJson({
        'meetings': [_memberJson(), _nonMemberJson()],
      });

      expect(models.map((model) => model.id), ['m1', 'm2']);
      expect(CalendarMeetingModel.listFromJson({'meetings': []}), isEmpty);
    });

    test('rejects a response without the meetings list', () {
      expect(
        () => CalendarMeetingModel.listFromJson({}),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => CalendarMeetingModel.listFromJson({'meetings': null}),
        throwsA(isA<FormatException>()),
      );
    });

    test('skips a malformed meeting and keeps the others', () {
      final models = CalendarMeetingModel.listFromJson({
        'meetings': [
          _memberJson(),
          {..._memberJson(), 'id': 'bad-date', 'date': 'amanhã'},
          {..._memberJson(), 'id': 'no-group', 'group': null},
          'not a meeting',
          _nonMemberJson(),
        ],
      });

      expect(models.map((model) => model.id), ['m1', 'm2']);
    });
  });
}
