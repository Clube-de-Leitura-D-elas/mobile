import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/books/data/models/book_details_model.dart';
import 'package:mobile/features/books/data/models/book_review_model.dart';
import 'package:mobile/features/books/domain/entities/book_review_entity.dart';
import 'package:mobile/features/books/domain/entities/book_reading_status.dart';

Map<String, dynamic> _details({
  Object? myStatus = 'READ',
  Object? myReview,
  Object? ratingAverage = 4.5,
}) => {
  'id': 'b1',
  'title': 'Harry Potter e a Pedra Filosofal',
  'author': 'J. K. Rowling',
  'genre': 'Fantasia',
  'publisher': 'Rocco',
  'synopsis': 'Um garoto órfão descobre que é bruxo.',
  'cover_url': 'https://example.com/capa.jpg',
  'rating_average': ratingAverage,
  'ratings_count': 12,
  'my_status': myStatus,
  'my_review': myReview,
  'reviews': {
    'items': [
      {
        'id': 'r1',
        'user': {
          'id': 'u1',
          'name': 'Roberta Fiore',
          'photo_url': 'https://example.com/roberta.jpg',
        },
        'rating': 5,
        'commentary': 'Muito envolvente.',
        'evaluated_at': '2026-11-01T12:00:00+00:00',
      },
    ],
    'has_more': true,
  },
};

void main() {
  group('BookDetailsModel', () {
    test('parses the get-book-details response', () {
      final details = BookDetailsModel.fromJson(
        _details(
          myReview: {
            'rating': 4,
            'commentary': 'Gostei',
            'evaluated_at': '2026-11-02T10:00:00+00:00',
          },
        ),
      ).toDomain();

      expect(details.id, 'b1');
      expect(details.title, 'Harry Potter e a Pedra Filosofal');
      expect(details.author, 'J. K. Rowling');
      expect(details.genre, 'Fantasia');
      expect(details.publisher, 'Rocco');
      expect(details.synopsis, 'Um garoto órfão descobre que é bruxo.');
      expect(details.coverUrl, 'https://example.com/capa.jpg');
      expect(details.ratingAverage, 4.5);
      expect(details.ratingsCount, 12);
      expect(details.myStatus, BookReadingStatus.read);
      expect(
        details.myReview,
        MyBookReviewEntity(
          rating: 4,
          commentary: 'Gostei',
          evaluatedAt: DateTime.utc(2026, 11, 2, 10),
        ),
      );
      expect(details.reviews, [
        BookReviewEntity(
          id: 'r1',
          userName: 'Roberta Fiore',
          userPhotoUrl: 'https://example.com/roberta.jpg',
          rating: 5,
          commentary: 'Muito envolvente.',
          evaluatedAt: DateTime.utc(2026, 11, 1, 12),
        ),
      ]);
      expect(details.hasMoreReviews, isTrue);
    });

    test('accepts a book without ratings, status, review or reviews', () {
      final details = BookDetailsModel.fromJson({
        ..._details(myStatus: null, ratingAverage: null),
        'reviews': {'items': <dynamic>[], 'has_more': false},
      }).toDomain();

      expect(details.ratingAverage, isNull);
      expect(details.myStatus, isNull);
      expect(details.myReview, isNull);
      expect(details.reviews, isEmpty);
      expect(details.hasMoreReviews, isFalse);
    });

    test('reads an integer average as double', () {
      final details = BookDetailsModel.fromJson(
        _details(ratingAverage: 4),
      ).toDomain();

      expect(details.ratingAverage, 4.0);
    });
  });

  group('BookReviewModel.resultFromJson', () {
    test('parses the upsert-book-review response', () {
      final result = BookReviewModel.resultFromJson({
        'id': 'r9',
        'rating': 3,
        'commentary': null,
        'evaluated_at': '2026-11-07T09:00:00+00:00',
        'rating_average': 3.5,
        'ratings_count': 13,
        'my_status': 'READ',
      });

      expect(
        result,
        BookReviewResultEntity(
          review: MyBookReviewEntity(
            rating: 3,
            evaluatedAt: DateTime.utc(2026, 11, 7, 9),
          ),
          ratingAverage: 3.5,
          ratingsCount: 13,
          myStatus: BookReadingStatus.read,
        ),
      );
    });
  });
}
