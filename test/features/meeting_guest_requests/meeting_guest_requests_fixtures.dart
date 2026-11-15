import 'package:mobile/features/meeting_guest_requests/domain/entities/meeting_guest_request_entity.dart';

const meetingId = '11111111-1111-1111-1111-111111111111';
const anaRequestId = '22222222-2222-2222-2222-222222222222';
const biaRequestId = '33333333-3333-3333-3333-333333333333';

// 13-11-2026 às 12:30 UTC é 09:30 em São Paulo.
final anaRequest = MeetingGuestRequestEntity(
  id: anaRequestId,
  userId: 'user-ana',
  name: 'Ana Souza',
  photoUrl: 'https://example.com/ana.png',
  requestedAt: DateTime.utc(2026, 11, 13, 12, 30),
);

const biaRequest = MeetingGuestRequestEntity(
  id: biaRequestId,
  userId: 'user-bia',
  name: 'Bia Lima',
);

Map<String, dynamic> guestRequestJson({
  Object? requestedAt = '2026-11-13T12:30:00+00:00',
  Object? photoUrl = 'https://example.com/ana.png',
}) => {
  'request_id': anaRequestId,
  'requested_at': requestedAt,
  'user': {'id': 'user-ana', 'name': 'Ana Souza', 'photo_url': photoUrl},
};
