import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/books/data/models/book_recommendation_group_model.dart';

void main() {
  test('parses and maps a recommendation group', () {
    final model = BookRecommendationGroupModel.fromJson(const {
      'group_id': 'g1',
      'name': 'Grupo Aurora',
      'photo_url': 'https://example.com/group.jpg',
      'already_recommended': true,
    });

    expect(model.id, 'g1');
    expect(model.name, 'Grupo Aurora');
    expect(model.photoUrl, 'https://example.com/group.jpg');
    expect(model.alreadyRecommended, isTrue);
    expect(model.toDomain().id, 'g1');
  });

  test('parses a group without a photo', () {
    final model = BookRecommendationGroupModel.fromJson(const {
      'group_id': 'g1',
      'name': 'Grupo Aurora',
      'photo_url': null,
      'already_recommended': false,
    });

    expect(model.photoUrl, isNull);
  });

  test('rejects invalid group payloads', () {
    expect(
      () => BookRecommendationGroupModel.fromJson(const <String, dynamic>{}),
      throwsFormatException,
    );
    expect(
      () => BookRecommendationGroupModel.fromJson('invalid'),
      throwsFormatException,
    );
    expect(
      () => BookRecommendationGroupModel.fromJson(const {
        'group_id': 'g1',
        'name': 'Grupo',
        'photo_url': 42,
        'already_recommended': false,
      }),
      throwsFormatException,
    );
  });

  test('rejects invalid list payloads and items', () {
    expect(
      () => BookRecommendationGroupModel.listFromJson(const {}),
      throwsFormatException,
    );
    expect(
      () => BookRecommendationGroupModel.listFromJson({
        'items': [
          {'group_id': 'g1', 'name': 'Grupo', 'already_recommended': 'false'},
        ],
      }),
      throwsFormatException,
    );
  });
}
