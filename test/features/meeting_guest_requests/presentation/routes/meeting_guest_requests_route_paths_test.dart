import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/meeting_guest_requests/presentation/routes/meeting_guest_requests_route_paths.dart';

void main() {
  test('builds the guest requests route for the meeting', () {
    expect(
      MeetingGuestRequestsRoutePaths.guestRequestsFor('m 1'),
      '/meeting-guest-requests?meeting_id=m+1',
    );
  });
}
