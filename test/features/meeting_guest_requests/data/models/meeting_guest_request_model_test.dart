import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/meeting_guest_requests/data/models/meeting_guest_request_model.dart';

import '../../meeting_guest_requests_fixtures.dart';

void main() {
  group('MeetingGuestRequestModel.fromJson', () {
    test('maps the request and the reader', () {
      final entity = MeetingGuestRequestModel.fromJson(
        guestRequestJson(),
      ).toDomain();

      expect(entity, anaRequest);
      expect(entity.requestedAt!.isUtc, isTrue);
    });

    test('accepts a request without date or photo', () {
      final entity = MeetingGuestRequestModel.fromJson(
        guestRequestJson(requestedAt: null, photoUrl: null),
      ).toDomain();

      expect(entity.requestedAt, isNull);
      expect(entity.photoUrl, isNull);
      expect(entity.name, 'Ana Souza');
    });

    test('ignores an unreadable date', () {
      final entity = MeetingGuestRequestModel.fromJson(
        guestRequestJson(requestedAt: 'ontem'),
      ).toDomain();

      expect(entity.requestedAt, isNull);
    });

    test('rejects a request without the reader', () {
      expect(
        () => MeetingGuestRequestModel.fromJson({
          'request_id': anaRequestId,
          'requested_at': null,
        }),
        throwsA(isA<TypeError>()),
      );
    });
  });

  group('MeetingGuestRequestModel.listFromJson', () {
    test('reads the requests in the order the backend sent', () {
      final models = MeetingGuestRequestModel.listFromJson({
        'requests': [
          guestRequestJson(),
          {
            'request_id': biaRequestId,
            'requested_at': null,
            'user': {'id': 'user-bia', 'name': 'Bia Lima', 'photo_url': null},
          },
        ],
      });

      expect(
        [for (final model in models) model.toDomain()],
        [anaRequest, biaRequest],
      );
    });

    test('an empty list has no requests', () {
      expect(MeetingGuestRequestModel.listFromJson({'requests': []}), isEmpty);
    });

    test('rejects a response without the requests list', () {
      expect(
        () => MeetingGuestRequestModel.listFromJson({'items': []}),
        throwsA(isA<TypeError>()),
      );
    });
  });
}
