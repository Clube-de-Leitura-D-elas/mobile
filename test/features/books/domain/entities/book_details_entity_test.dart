import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/books/domain/entities/book_details_entity.dart';
import 'package:mobile/features/books/domain/entities/book_review_entity.dart';
import 'package:mobile/features/books/domain/entities/book_reading_status.dart';

void main() {
  final review = BookReviewEntity(
    id: 'r1',
    userName: 'Roberta',
    rating: 5,
    evaluatedAt: DateTime.utc(2026, 11, 1),
  );

  final details = BookDetailsEntity(
    id: 'b1',
    title: 'Livro',
    author: 'Autora',
    genre: 'Fantasia',
    publisher: 'Rocco',
    synopsis: 'Sinopse',
    coverUrl: 'https://example.com/capa.jpg',
    ratingAverage: 4,
    ratingsCount: 2,
    myStatus: BookReadingStatus.read,
    reviews: [review],
    hasMoreReviews: true,
  );

  test('withReadingStatus changes only the status, including to none', () {
    final cleared = details.withReadingStatus(null);

    expect(cleared.myStatus, isNull);
    expect(cleared.withReadingStatus(BookReadingStatus.read), details);
  });

  test('withReview applies the saved review, average and status', () {
    final saved = MyBookReviewEntity(
      rating: 3,
      evaluatedAt: DateTime.utc(2026, 11, 7),
    );

    final updated = details
        .withReadingStatus(null)
        .withReview(
          BookReviewResultEntity(
            review: saved,
            ratingAverage: 3.5,
            ratingsCount: 3,
            myStatus: BookReadingStatus.read,
          ),
        );

    expect(updated.myReview, saved);
    expect(updated.ratingAverage, 3.5);
    expect(updated.ratingsCount, 3);
    expect(updated.myStatus, BookReadingStatus.read);
    expect(updated.reviews, [review]);
    expect(updated.hasMoreReviews, isTrue);
    expect(updated.title, details.title);
  });
}
