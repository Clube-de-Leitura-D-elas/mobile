import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/calendar/domain/entities/calendar_guest_status.dart';
import 'package:mobile/features/calendar/domain/entities/calendar_meeting_status.dart';
import 'package:mobile/features/calendar/domain/entities/calendar_membership_status.dart';

import '../../calendar_fixtures.dart';

void main() {
  // 12h de 14/08 em São Paulo.
  final now = DateTime.utc(2026, 8, 14, 15);

  group('guest participation', () {
    test('follows can_request_participation from the backend', () {
      final allowed = calendarMeeting(
        'm',
        day: DateTime(2026, 8, 20),
        membership: CalendarMembershipStatus.none,
        canRequestParticipation: true,
      );
      final blocked = calendarMeeting(
        'm',
        day: DateTime(2026, 8, 20),
        membership: CalendarMembershipStatus.none,
      );

      expect(allowed.canRequestParticipationAt(now), isTrue);
      expect(blocked.canRequestParticipationAt(now), isFalse);
    });

    test('a meeting that started or closed since the load no longer takes '
        'requests, even when the backend allowed it', () {
      final started = calendarMeeting(
        'started',
        day: DateTime(2026, 8, 14),
        hour: 11,
        canRequestParticipation: true,
      );
      final rightNow = calendarMeeting(
        'now',
        day: DateTime(2026, 8, 14),
        hour: 12,
        canRequestParticipation: true,
      );
      final inProgress = calendarMeeting(
        'in-progress',
        day: DateTime(2026, 8, 20),
        status: CalendarMeetingStatus.inProgress,
        canRequestParticipation: true,
      );

      for (final meeting in [started, rightNow, inProgress]) {
        expect(meeting.isOpenAt(now), isFalse, reason: meeting.id);
        expect(
          meeting.canRequestParticipationAt(now),
          isFalse,
          reason: meeting.id,
        );
      }
    });

    test('asRequested waits for approval with no new action and keeps the '
        'rest of the meeting', () {
      final meeting = calendarMeeting(
        'm',
        day: DateTime(2026, 8, 20),
        membership: CalendarMembershipStatus.none,
        neighborhood: 'Moinhos',
        guestStatus: CalendarGuestStatus.rejected,
        canRequestParticipation: true,
      );

      final updated = meeting.asRequested();

      expect(updated.guestStatus, CalendarGuestStatus.requested);
      expect(updated.canRequestParticipationAt(now), isFalse);
      expect(updated, isNot(meeting));
      expect(updated.neighborhood, 'Moinhos');
      expect(updated.group, meeting.group);
      expect(updated.date, meeting.date);
    });
  });
}
