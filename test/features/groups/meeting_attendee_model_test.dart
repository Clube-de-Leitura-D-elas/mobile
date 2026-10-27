import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/groups/data/models/meeting_attendance_model.dart';

void main() {
  const attendee = {
    'id': 'group-user-1',
    'name': 'Ana',
    'photo_url': null,
    'invitation_status': 'CONFIRMED',
    'presence_status': null,
  };

  test('parses the attendance envelope', () {
    expect(
      MeetingAttendanceModel.listFromJson({
        'data': [attendee],
      }),
      hasLength(1),
    );
  });

  test('parses the legacy direct attendance list', () {
    expect(MeetingAttendanceModel.listFromJson([attendee]), hasLength(1));
  });
}
