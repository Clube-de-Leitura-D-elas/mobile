import 'package:mobile/features/books/data/models/book_reading_status_model.dart';
import 'package:mobile/features/books/domain/entities/book_review_entity.dart';

abstract final class BookReviewModel {
  static BookReviewEntity reviewFromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? const {};
    return BookReviewEntity(
      id: json['id'] as String,
      userName: user['name'] as String? ?? '',
      userPhotoUrl: user['photo_url'] as String?,
      rating: (json['rating'] as num).toInt(),
      commentary: json['commentary'] as String?,
      evaluatedAt: DateTime.parse(json['evaluated_at'] as String),
    );
  }

  static MyBookReviewEntity myReviewFromJson(Map<String, dynamic> json) {
    return MyBookReviewEntity(
      rating: (json['rating'] as num).toInt(),
      commentary: json['commentary'] as String?,
      evaluatedAt: DateTime.parse(json['evaluated_at'] as String),
    );
  }

  /// Resposta da upsert-book-review.
  static BookReviewResultEntity resultFromJson(Map<String, dynamic> json) {
    return BookReviewResultEntity(
      review: myReviewFromJson(json),
      ratingAverage: (json['rating_average'] as num?)?.toDouble(),
      ratingsCount: (json['ratings_count'] as num?)?.toInt() ?? 0,
      myStatus: bookReadingStatusFromWire(json['my_status']),
    );
  }
}
