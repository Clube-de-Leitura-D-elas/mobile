import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/groups/data/models/meeting_attendee_model.dart';

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
      MeetingAttendeeModel.listFromEnvelope({
        'attendees': [attendee],
      }),
      hasLength(1),
    );
  });

  test('parses the legacy direct attendance list', () {
    expect(MeetingAttendeeModel.listFromEnvelope([attendee]), hasLength(1));
  });
}
