import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/calendar/domain/entities/calendar_membership_status.dart';
import 'package:mobile/features/calendar/presentation/routes/calendar_route_paths.dart';

import '../../calendar_fixtures.dart';

void main() {
  test('a member goes to the group details', () {
    final meeting = calendarMeeting('m1', day: DateTime(2026, 8, 17));

    expect(
      CalendarRoutePaths.destinationFor(meeting),
      '/group-details?group_id=group-m1',
    );
  });

  for (final status in CalendarMembershipStatus.values.where(
    (status) => status != CalendarMembershipStatus.member,
  )) {
    test('a ${status.name} user goes to the public group page', () {
      final meeting = calendarMeeting(
        'm1',
        day: DateTime(2026, 8, 17),
        membership: status,
      );

      expect(
        CalendarRoutePaths.destinationFor(meeting),
        '/group-public?group_id=group-m1',
      );
    });
  }
}
