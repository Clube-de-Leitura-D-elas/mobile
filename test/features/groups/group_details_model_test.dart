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

    test('given json without whatsapp_url, when fromJson, whatsappUrl is null', () {
      final jsonWithoutWhatsapp = Map<String, dynamic>.from(validJson)
        ..remove('whatsapp_url');

      final model = GroupDetailsModel.fromJson(jsonWithoutWhatsapp);

      expect(model.whatsappUrl, isNull);
    });

    test('given model, when toDomain, returns entity with whatsappUrl', () {
      final model = GroupDetailsModel.fromJson(validJson);
      final entity = model.toDomain();

      expect(entity.whatsappUrl, 'https://chat.whatsapp.com/ABC123xyz');
    });
  });
}
