import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/group_discovery/data/models/group_search_page_model.dart';

import '../../group_discovery_fixtures.dart';

void main() {
  test('parses items and total', () {
    final page = GroupSearchPageModel.fromJson({
      'items': [discoveryGroupJson()],
      'total': 7,
    }).toDomain();

    expect(page.items.single.id, groupId);
    expect(page.total, 7);
  });

  test('parses an empty page', () {
    final page = GroupSearchPageModel.fromJson({
      'items': <dynamic>[],
      'total': 0,
    }).toDomain();

    expect(page.items, isEmpty);
    expect(page.total, 0);
  });
}
