import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/calendar/domain/entities/calendar_guest_status.dart';
import 'package:mobile/features/calendar/domain/entities/calendar_meeting_status.dart';
import 'package:mobile/features/calendar/domain/entities/calendar_membership_status.dart';

import '../../calendar_fixtures.dart';

void main() {
  // 12h de 14/08 em São Paulo.
  final now = DateTime.utc(2026, 8, 14, 15);

  group('guest participation', () {
    test('a scheduled future meeting of another group accepts a request', () {
      final meeting = calendarMeeting(
        'm',
        day: DateTime(2026, 8, 20),
        membership: CalendarMembershipStatus.none,
      );

      expect(meeting.acceptsGuestRequestAt(now), isTrue);
      expect(meeting.canRequestParticipationAt(now), isTrue);
    });

    for (final membership in [
      CalendarMembershipStatus.member,
      CalendarMembershipStatus.requested,
      CalendarMembershipStatus.rejected,
      CalendarMembershipStatus.pending,
    ]) {
      test('a reader with a ${membership.name} link to the group never sees '
          'the guest request', () {
        final meeting = calendarMeeting(
          'm',
          day: DateTime(2026, 8, 20),
          membership: membership,
        );

        expect(meeting.acceptsGuestRequestAt(now), isFalse);
        expect(meeting.canRequestParticipationAt(now), isFalse);
      });
    }

    test('a past, started or not scheduled meeting does not accept it', () {
      final past = calendarMeeting(
        'past',
        day: DateTime(2026, 8, 14),
        hour: 11,
        membership: CalendarMembershipStatus.none,
      );
      final rightNow = calendarMeeting(
        'now',
        day: DateTime(2026, 8, 14),
        hour: 12,
        membership: CalendarMembershipStatus.none,
      );
      final inProgress = calendarMeeting(
        'in-progress',
        day: DateTime(2026, 8, 20),
        status: CalendarMeetingStatus.inProgress,
        membership: CalendarMembershipStatus.none,
      );
      final ended = calendarMeeting(
        'ended',
        day: DateTime(2026, 8, 20),
        status: CalendarMeetingStatus.ended,
        membership: CalendarMembershipStatus.none,
      );

      for (final meeting in [past, rightNow, inProgress, ended]) {
        expect(meeting.acceptsGuestRequestAt(now), isFalse, reason: meeting.id);
      }
    });

    test('only "no request" and "rejected" can request again', () {
      final expected = <CalendarGuestStatus?, bool>{
        null: true,
        CalendarGuestStatus.rejected: true,
        CalendarGuestStatus.requested: false,
        CalendarGuestStatus.accepted: false,
        CalendarGuestStatus.unknown: false,
      };
      for (final MapEntry(key: status, value: canRequest) in expected.entries) {
        final meeting = calendarMeeting(
          'm',
          day: DateTime(2026, 8, 20),
          membership: CalendarMembershipStatus.none,
          guestStatus: status,
        );
        expect(
          meeting.canRequestParticipationAt(now),
          canRequest,
          reason: '$status',
        );
      }
    });

    test('copyWithGuestStatus keeps the rest of the meeting', () {
      final meeting = calendarMeeting(
        'm',
        day: DateTime(2026, 8, 20),
        membership: CalendarMembershipStatus.none,
        neighborhood: 'Moinhos',
      );

      final updated = meeting.copyWithGuestStatus(
        CalendarGuestStatus.requested,
      );

      expect(updated.guestStatus, CalendarGuestStatus.requested);
      expect(updated, isNot(meeting), reason: 'guestStatus entra na igualdade');
      expect(
        updated.copyWithGuestStatus(CalendarGuestStatus.requested),
        updated,
      );
      expect(updated.neighborhood, 'Moinhos');
      expect(updated.group, meeting.group);
      expect(updated.date, meeting.date);
    });
  });
}
