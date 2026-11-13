import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/group_join_requests/data/models/group_join_request_model.dart';

import '../../group_join_requests_fixtures.dart';

void main() {
  group('GroupJoinRequestModel.fromJson', () {
    test('maps the request and the reader', () {
      final entity = GroupJoinRequestModel.fromJson(
        joinRequestJson(),
      ).toDomain();

      expect(entity, anaRequest);
      expect(entity.requestedAt!.isUtc, isTrue);
    });

    test('accepts a request without date or photo', () {
      final entity = GroupJoinRequestModel.fromJson(
        joinRequestJson(requestedAt: null, photoUrl: null),
      ).toDomain();

      expect(entity.requestedAt, isNull);
      expect(entity.photoUrl, isNull);
      expect(entity.name, 'Ana Souza');
    });

    test('ignores an unreadable date', () {
      final entity = GroupJoinRequestModel.fromJson(
        joinRequestJson(requestedAt: 'ontem'),
      ).toDomain();

      expect(entity.requestedAt, isNull);
    });

    test('rejects a request without the reader', () {
      expect(
        () => GroupJoinRequestModel.fromJson({
          'group_user_id': anaRequestId,
          'requested_at': null,
        }),
        throwsA(isA<TypeError>()),
      );
    });
  });

  group('GroupJoinRequestModel.listFromJson', () {
    test('reads the requests in the order the backend sent', () {
      final models = GroupJoinRequestModel.listFromJson({
        'requests': [
          joinRequestJson(),
          {
            'group_user_id': biaRequestId,
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
      expect(GroupJoinRequestModel.listFromJson({'requests': []}), isEmpty);
    });

    test('rejects a response without the requests list', () {
      expect(
        () => GroupJoinRequestModel.listFromJson({'items': []}),
        throwsA(isA<TypeError>()),
      );
    });
  });
}
