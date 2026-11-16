import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/books/domain/entities/book_reading_status.dart';
import 'package:mobile/features/books/presentation/routes/book_recommendation_target.dart';

void main() {
  test('stores recommendation target data', () {
    const target = BookRecommendationTarget(
      groupId: 'g1',
      groupName: 'Grupo Aurora',
    );

    expect(target.groupId, 'g1');
    expect(target.groupName, 'Grupo Aurora');
  });

  test('stores optional route extras', () {
    void onStatusChanged(BookReadingStatus? status, {required bool isWrite}) {}

    final extra = BookDetailsRouteExtra(
      onReadingStatusChanged: onStatusChanged,
      recommendationTarget: const BookRecommendationTarget(
        groupId: 'g1',
        groupName: 'Grupo Aurora',
      ),
    );

    expect(extra.onReadingStatusChanged, same(onStatusChanged));
    expect(extra.recommendationTarget?.groupId, 'g1');
  });
}
