import 'package:mobile/features/books/domain/entities/book_reading_status.dart';

class BookRecommendationTarget {
  const BookRecommendationTarget({
    required this.groupId,
    required this.groupName,
  });

  final String groupId;
  final String groupName;
}

class BookDetailsRouteExtra {
  const BookDetailsRouteExtra({
    this.onReadingStatusChanged,
    this.recommendationTarget,
  });

  final void Function(BookReadingStatus? status, {required bool isWrite})?
  onReadingStatusChanged;
  final BookRecommendationTarget? recommendationTarget;
}
