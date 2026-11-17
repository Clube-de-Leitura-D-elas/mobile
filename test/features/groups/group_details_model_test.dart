import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/groups/data/models/group_details_model.dart';

void main() {
  group('GroupDetailsModel', () {
    const validJson = {
      'name': 'Grupo 1',
      'genres': ['Ficção', 'Romance'],
      'participant_count': 12,
      'city': 'São Paulo',
      'state_code': 'SP',
      'cover_image_url': 'https://example.com/cover.jpg',
      'whatsapp_url': 'https://chat.whatsapp.com/ABC123xyz',
    };

    test('given json with whatsapp_url, when fromJson, parses whatsappUrl', () {
      final model = GroupDetailsModel.fromJson(validJson);

      expect(model.name, 'Grupo 1');
      expect(model.whatsappUrl, 'https://chat.whatsapp.com/ABC123xyz');
    });

    test(
      'given json without whatsapp_url, when fromJson, whatsappUrl is null',
      () {
        final jsonWithoutWhatsapp = Map<String, dynamic>.from(validJson)
          ..remove('whatsapp_url');

        final model = GroupDetailsModel.fromJson(jsonWithoutWhatsapp);

        expect(model.whatsappUrl, isNull);
      },
    );

    test(
      'given json with null whatsapp_url, when fromJson, then whatsappUrl is null',
      () {
        final json = Map<String, dynamic>.from(validJson)
          ..['whatsapp_url'] = null;

        final model = GroupDetailsModel.fromJson(json);

        expect(model.whatsappUrl, isNull);
      },
    );

    test(
      'given json with non-string whatsapp_url, when fromJson, then throws FormatException',
      () {
        final json = Map<String, dynamic>.from(validJson)
          ..['whatsapp_url'] = 123;

        expect(() => GroupDetailsModel.fromJson(json), throwsFormatException);
      },
    );

    test('given model, when toDomain, returns entity with whatsappUrl', () {
      final model = GroupDetailsModel.fromJson(validJson);
      final entity = model.toDomain();

      expect(entity.whatsappUrl, 'https://chat.whatsapp.com/ABC123xyz');
    });

    test('parses pending_raffle and open meeting fields correctly', () {
      final jsonInaugural = Map<String, dynamic>.from(validJson)
        ..['pending_raffle'] = {
          'type': 'INAUGURAL',
          'group_id': 'g-1',
        }
        ..['has_open_meeting'] = false
        ..['open_meeting_status'] = null;

      final modelInaugural = GroupDetailsModel.fromJson(jsonInaugural);
      expect(modelInaugural.pendingRaffle?.type.name, 'inaugural');
      expect(modelInaugural.hasOpenMeeting, isFalse);
      expect(modelInaugural.openMeetingStatus, isNull);

      final jsonPending = Map<String, dynamic>.from(validJson)
        ..['pending_raffle'] = {
          'type': 'PENDING',
          'group_id': 'g-1',
          'meeting_id': 'm-1',
        }
        ..['has_open_meeting'] = true
        ..['open_meeting_status'] = 'CREATED';

      final modelPending = GroupDetailsModel.fromJson(jsonPending);
      expect(modelPending.pendingRaffle?.type.name, 'pending');
      expect(modelPending.pendingRaffle?.meetingId, 'm-1');
      expect(modelPending.hasOpenMeeting, isTrue);
      expect(modelPending.openMeetingStatus, 'CREATED');

      final domain = modelPending.toDomain();
      expect(domain.pendingRaffle?.type.name, 'pending');
      expect(domain.hasOpenMeeting, isTrue);
      expect(domain.openMeetingStatus, 'CREATED');
    });

    test('ignores invalid or null pending_raffle', () {
      final jsonNull = Map<String, dynamic>.from(validJson)
        ..['pending_raffle'] = null;
      expect(GroupDetailsModel.fromJson(jsonNull).pendingRaffle, isNull);

      final jsonNotMap = Map<String, dynamic>.from(validJson)
        ..['pending_raffle'] = 123;
      expect(GroupDetailsModel.fromJson(jsonNotMap).pendingRaffle, isNull);

      final jsonNoGroup = Map<String, dynamic>.from(validJson)
        ..['pending_raffle'] = {'type': 'INAUGURAL'};
      expect(GroupDetailsModel.fromJson(jsonNoGroup).pendingRaffle, isNull);
    });
  });
}
