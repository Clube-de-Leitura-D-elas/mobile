import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/group_discovery/data/models/group_search_page_model.dart';
import 'package:mobile/features/group_discovery/domain/entities/group_genre_entity.dart';

import '../../group_discovery_fixtures.dart';

void main() {
  test('parses items, total and the genre options', () {
    final page = GroupSearchPageModel.fromJson({
      'items': [discoveryGroupJson()],
      'total': 7,
      'genres': [
        {'id': 'g-2', 'name': 'Aventura'},
        {'id': 'g-1', 'name': 'Ficção'},
      ],
    }).toDomain();

    expect(page.items.single.id, groupId);
    expect(page.total, 7);
    expect(page.genres, const [
      GroupGenreEntity(id: 'g-2', name: 'Aventura'),
      GroupGenreEntity(id: 'g-1', name: 'Ficção'),
    ]);
  });

  test('parses an empty page', () {
    final page = GroupSearchPageModel.fromJson({
      'items': <dynamic>[],
      'total': 0,
      'genres': <dynamic>[],
    }).toDomain();

    expect(page.items, isEmpty);
    expect(page.total, 0);
    expect(page.genres, isEmpty);
  });
}
