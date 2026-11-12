import 'package:mobile/features/books/data/models/book_review_model.dart';
import 'package:mobile/features/books/data/models/book_reading_status_model.dart';
import 'package:mobile/features/books/domain/entities/book_details_entity.dart';
import 'package:mobile/features/books/domain/entities/book_review_entity.dart';
import 'package:mobile/features/books/domain/entities/book_reading_status.dart';

class BookDetailsModel {
  final String id;
  final String title;
  final String author;
  final String genre;
  final String publisher;
  final String? synopsis;
  final String? coverUrl;
  final double? ratingAverage;
  final int ratingsCount;
  final BookReadingStatus? myStatus;
  final MyBookReviewEntity? myReview;
  final List<BookReviewEntity> reviews;
  final bool hasMoreReviews;

  const BookDetailsModel({
    required this.id,
    required this.title,
    required this.author,
    required this.genre,
    required this.publisher,
    required this.ratingsCount,
    required this.reviews,
    required this.hasMoreReviews,
    this.synopsis,
    this.coverUrl,
    this.ratingAverage,
    this.myStatus,
    this.myReview,
  });

  factory BookDetailsModel.fromJson(Map<String, dynamic> json) {
    final reviews = json['reviews'] as Map<String, dynamic>? ?? const {};
    final myReview = json['my_review'];

    return BookDetailsModel(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String? ?? '',
      genre: json['genre'] as String? ?? '',
      publisher: json['publisher'] as String? ?? '',
      synopsis: json['synopsis'] as String?,
      coverUrl: json['cover_url'] as String?,
      ratingAverage: (json['rating_average'] as num?)?.toDouble(),
      ratingsCount: (json['ratings_count'] as num?)?.toInt() ?? 0,
      myStatus: bookReadingStatusFromWire(json['my_status']),
      myReview: myReview is Map<String, dynamic>
          ? BookReviewModel.myReviewFromJson(myReview)
          : null,
      reviews: (reviews['items'] as List<dynamic>? ?? const [])
          .map(
            (item) =>
                BookReviewModel.reviewFromJson(item as Map<String, dynamic>),
          )
          .toList(),
      hasMoreReviews: reviews['has_more'] as bool? ?? false,
    );
  }

  BookDetailsEntity toDomain() {
    return BookDetailsEntity(
      id: id,
      title: title,
      author: author,
      genre: genre,
      publisher: publisher,
      synopsis: synopsis,
      coverUrl: coverUrl,
      ratingAverage: ratingAverage,
      ratingsCount: ratingsCount,
      myStatus: myStatus,
      myReview: myReview,
      reviews: reviews,
      hasMoreReviews: hasMoreReviews,
    );
  }
}
