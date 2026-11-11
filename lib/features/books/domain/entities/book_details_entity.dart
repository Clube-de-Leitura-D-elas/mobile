import 'package:equatable/equatable.dart';
import 'package:mobile/features/books/domain/entities/book_review_entity.dart';
import 'package:mobile/features/books/domain/entities/reading_status.dart';

class BookDetailsEntity extends Equatable {
  final String id;
  final String title;
  final String author;
  final String genre;
  final String publisher;
  final String? synopsis;
  final String? coverUrl;

  /// Média arredondada à meia estrela; `null` sem avaliações.
  final double? ratingAverage;
  final int ratingsCount;
  final ReadingStatus? myStatus;
  final MyBookReviewEntity? myReview;

  /// Página de avaliações das outras leitoras pedida junto com os detalhes.
  final List<BookReviewEntity> reviews;
  final bool hasMoreReviews;

  const BookDetailsEntity({
    required this.id,
    required this.title,
    required this.author,
    required this.genre,
    required this.publisher,
    required this.ratingsCount,
    this.synopsis,
    this.coverUrl,
    this.ratingAverage,
    this.myStatus,
    this.myReview,
    this.reviews = const [],
    this.hasMoreReviews = false,
  });

  BookDetailsEntity withReadingStatus(ReadingStatus? status) =>
      _copy(myStatus: status);

  BookDetailsEntity withReview(BookReviewResultEntity result) => _copy(
    myStatus: result.myStatus,
    myReview: result.review,
    ratingAverage: result.ratingAverage,
    ratingsCount: result.ratingsCount,
  );

  BookDetailsEntity _copy({
    required ReadingStatus? myStatus,
    MyBookReviewEntity? myReview,
    double? ratingAverage,
    int? ratingsCount,
  }) {
    return BookDetailsEntity(
      id: id,
      title: title,
      author: author,
      genre: genre,
      publisher: publisher,
      synopsis: synopsis,
      coverUrl: coverUrl,
      ratingAverage: ratingAverage ?? this.ratingAverage,
      ratingsCount: ratingsCount ?? this.ratingsCount,
      myStatus: myStatus,
      myReview: myReview ?? this.myReview,
      reviews: reviews,
      hasMoreReviews: hasMoreReviews,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    author,
    genre,
    publisher,
    synopsis,
    coverUrl,
    ratingAverage,
    ratingsCount,
    myStatus,
    myReview,
    reviews,
    hasMoreReviews,
  ];
}
