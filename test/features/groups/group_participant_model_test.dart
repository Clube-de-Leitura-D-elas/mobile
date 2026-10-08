import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/groups/data/models/group_participant_model.dart';
import 'package:mobile/features/groups/domain/entities/group_participant_entity.dart';

void main() {
  group('GroupParticipantModel.fromJson', () {
    test('given a full participant, then maps every field', () {
      final model = GroupParticipantModel.fromJson(const {
        'id': 'p-1',
        'name': '  Ana Beatriz  ',
        'photo_url': 'https://example.com/ana.jpg',
        'role': 'coordinator',
      });

      expect(
        model.toDomain(),
        const GroupParticipantEntity(
          id: 'p-1',
          name: 'Ana Beatriz',
          photoUrl: 'https://example.com/ana.jpg',
          isCoordinator: true,
        ),
      );
    });

    test('given no photo and no role, then photo is null and is a member', () {
      final model = GroupParticipantModel.fromJson(const {
        'id': 'p-2',
        'name': 'Carla',
      });

      expect(model.photoUrl, isNull);
      expect(model.isCoordinator, isFalse);
    });

    test('given a blank photo url, then treats it as no photo', () {
      final model = GroupParticipantModel.fromJson(const {
        'id': 'p-3',
        'name': 'Dora',
        'photo_url': '   ',
        'role': 'member',
      });

      expect(model.photoUrl, isNull);
      expect(model.isCoordinator, isFalse);
    });

    test('given an invalid payload, then throws FormatException', () {
      expect(
        () => GroupParticipantModel.fromJson(const {'id': 1, 'name': 'X'}),
        throwsFormatException,
      );
      expect(() => GroupParticipantModel.fromJson('x'), throwsFormatException);
    });
  });

  group('GroupParticipantModel.listFromJson', () {
    test('given a participants array, then decodes each entry', () {
      final list = GroupParticipantModel.listFromJson(const {
        'participants': [
          {'id': 'p-1', 'name': 'Ana'},
          {'id': 'p-2', 'name': 'Bia'},
        ],
      });

      expect(list.map((p) => p.id), ['p-1', 'p-2']);
    });

    test('given a response without participants, then throws', () {
      expect(
        () => GroupParticipantModel.listFromJson(const {'data': []}),
        throwsFormatException,
      );
    });
  });
}
