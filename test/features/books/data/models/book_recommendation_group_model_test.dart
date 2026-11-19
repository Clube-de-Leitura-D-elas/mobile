import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/books/data/models/book_recommendation_group_model.dart';
import 'package:mobile/features/books/domain/entities/book_recommendation_group.dart';

void main() {
  test('parses and maps a recommendation group', () {
    final model = BookRecommendationGroupModel.fromJson(const {
      'group_id': 'g1',
      'number': 1,
      'name': 'Grupo 1',
      'photo_url': 'https://example.com/group.jpg',
      'already_recommended': true,
      'can_recommend': false,
    });

    expect(model.id, 'g1');
    expect(model.number, 1);
    expect(model.name, 'Grupo 1');
    expect(model.photoUrl, 'https://example.com/group.jpg');
    expect(model.alreadyRecommended, isTrue);
    expect(model.canRecommend, isFalse);
    expect(
      model.toDomain(),
      const BookRecommendationGroup(
        id: 'g1',
        number: 1,
        name: 'Grupo 1',
        photoUrl: 'https://example.com/group.jpg',
        alreadyRecommended: true,
        canRecommend: false,
      ),
    );
  });

  test('defaults canRecommend to true when can_recommend is omitted or null', () {
    final omitted = BookRecommendationGroupModel.fromJson(const {
      'group_id': 'g1',
      'name': 'Grupo Aurora',
      'photo_url': null,
      'already_recommended': false,
    });
    final explicitNull = BookRecommendationGroupModel.fromJson(const {
      'group_id': 'g2',
      'name': 'Grupo Sol',
      'photo_url': null,
      'already_recommended': false,
      'can_recommend': null,
    });

    expect(omitted.canRecommend, isTrue);
    expect(explicitNull.canRecommend, isTrue);
  });

  test('parses a group list response', () {
    final models = BookRecommendationGroupModel.listFromJson(const {
      'items': [
        {
          'group_id': 'g1',
          'number': 1,
          'name': 'Grupo 1',
          'photo_url': null,
          'already_recommended': false,
        },
        {
          'group_id': 'g2',
          'number': 2,
          'name': 'Grupo 2',
          'photo_url': 'https://example.com/g2.jpg',
          'already_recommended': true,
        },
      ],
    });

    expect(models.map((m) => m.toDomain()).toList(), const [
      BookRecommendationGroup(
        id: 'g1',
        number: 1,
        name: 'Grupo 1',
        alreadyRecommended: false,
      ),
      BookRecommendationGroup(
        id: 'g2',
        number: 2,
        name: 'Grupo 2',
        photoUrl: 'https://example.com/g2.jpg',
        alreadyRecommended: true,
      ),
    ]);
  });

  test('parses a group without a photo or number', () {
    final model = BookRecommendationGroupModel.fromJson(const {
      'group_id': 'g1',
      'name': 'Grupo Aurora',
      'photo_url': null,
      'already_recommended': false,
    });

    expect(model.photoUrl, isNull);
    expect(model.number, isNull);
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
        'number': '1',
        'name': 'Grupo',
        'already_recommended': false,
      }),
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
    expect(
      () => BookRecommendationGroupModel.fromJson(const {
        'group_id': 'g1',
        'name': 'Grupo',
        'already_recommended': false,
        'can_recommend': 'true',
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

  test('copies BookRecommendationGroup with and without overrides', () {
    const original = BookRecommendationGroup(
      id: 'g1',
      number: 1,
      name: 'Grupo 1',
      photoUrl: 'https://example.com/g1.jpg',
      alreadyRecommended: false,
      canRecommend: true,
    );

    expect(original.copyWith(), original);
    expect(
      original.copyWith(alreadyRecommended: true, canRecommend: false),
      const BookRecommendationGroup(
        id: 'g1',
        number: 1,
        name: 'Grupo 1',
        photoUrl: 'https://example.com/g1.jpg',
        alreadyRecommended: true,
        canRecommend: false,
      ),
    );
  });
}
