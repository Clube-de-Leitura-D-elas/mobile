import 'package:equatable/equatable.dart';
import 'package:mobile/features/books/domain/entities/reading_status.dart';

/// Avaliação de outra leitora, exibida na lista de comentários.
class BookReviewEntity extends Equatable {
  final String id;
  final String userName;
  final String? userPhotoUrl;
  final int rating;
  final String? commentary;
  final DateTime evaluatedAt;

  const BookReviewEntity({
    required this.id,
    required this.userName,
    required this.rating,
    required this.evaluatedAt,
    this.userPhotoUrl,
    this.commentary,
  });

  @override
  List<Object?> get props => [
    id,
    userName,
    userPhotoUrl,
    rating,
    commentary,
    evaluatedAt,
  ];
}

/// Avaliação da própria leitora.
class MyBookReviewEntity extends Equatable {
  final int rating;
  final String? commentary;
  final DateTime evaluatedAt;

  const MyBookReviewEntity({
    required this.rating,
    required this.evaluatedAt,
    this.commentary,
  });

  @override
  List<Object?> get props => [rating, commentary, evaluatedAt];
}

/// Resultado de salvar a avaliação, com a média já recalculada.
class BookReviewResultEntity extends Equatable {
  final MyBookReviewEntity review;
  final double? ratingAverage;
  final int ratingsCount;
  final ReadingStatus? myStatus;

  const BookReviewResultEntity({
    required this.review,
    required this.ratingsCount,
    this.ratingAverage,
    this.myStatus,
  });

  @override
  List<Object?> get props => [review, ratingAverage, ratingsCount, myStatus];
}
