import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/supabase/supabase_failure.dart';
import 'package:mobile/core/supabase/supabase_response.dart';
import 'package:mobile/core/supabase/supabase_service.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/books/data/models/book_details_model.dart';
import 'package:mobile/features/books/data/repositories/book_repository_impl.dart';
import 'package:mobile/features/books/domain/entities/book_details_entity.dart';
import 'package:mobile/features/books/domain/entities/book_failure.dart';
import 'package:mobile/features/books/domain/entities/book_review_entity.dart';
import 'package:mobile/features/books/domain/entities/reading_status.dart';
import 'package:mobile/features/books/domain/repository/book_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show HttpMethod;

class MockSupabaseService extends Mock implements SupabaseService {}

void main() {
  late MockSupabaseService service;
  late BookRepositoryImpl repository;

  setUpAll(() => registerFallbackValue(HttpMethod.post));

  setUp(() {
    service = MockSupabaseService();
    repository = BookRepositoryImpl(supabaseService: service);
  });

  group('getBookDetails', () {
    void stubDetails(
      Result<SupabaseResponse<BookDetailsModel>, SupabaseFailure> result,
    ) {
      when(
        () => service.invokeFunction<BookDetailsModel>(
          functionName: any(named: 'functionName'),
          method: any(named: 'method'),
          queryParameters: any(named: 'queryParameters'),
          decoder: any(named: 'decoder'),
        ),
      ).thenAnswer((_) async => result);
    }

    test('sends a GET with the book and the reviews page', () async {
      stubDetails(
        const Success(
          SupabaseResponse(
            data: BookDetailsModel(
              id: 'b1',
              title: 'Livro',
              author: 'Autora',
              genre: '',
              publisher: '',
              ratingsCount: 0,
              reviews: [],
              hasMoreReviews: false,
            ),
          ),
        ),
      );

      final result = await repository.getBookDetails(
        bookId: 'b1',
        reviewsPage: 2,
      );

      expect(result.unwrap().title, 'Livro');
      final call = verify(
        () => service.invokeFunction<BookDetailsModel>(
          functionName: 'get-book-details',
          method: HttpMethod.get,
          queryParameters: {
            'bookId': 'b1',
            'reviewsPage': '2',
            'reviewsPageSize': '${BookRepository.reviewsPageSize}',
          },
          decoder: captureAny(named: 'decoder'),
        ),
      )..called(1);

      final decoder =
          call.captured.single as BookDetailsModel Function(dynamic);
      expect(
        decoder({
          'id': 'b2',
          'title': 'Outro',
          'ratings_count': 0,
          'reviews': {'items': <dynamic>[], 'has_more': false},
        }).title,
        'Outro',
      );
    });

    test('maps 404 to BookNotFoundFailure', () async {
      stubDetails(
        const Failure(FunctionSupabaseFailure(message: 'x', code: '404')),
      );

      expect(
        await repository.getBookDetails(bookId: 'b1'),
        const Failure<BookDetailsEntity, BookFailure>(BookNotFoundFailure()),
      );
    });

    test(
      'maps other failures and empty data to BookDetailsLoadFailure',
      () async {
        stubDetails(
          const Failure(FunctionSupabaseFailure(message: 'x', code: '500')),
        );
        expect(
          await repository.getBookDetails(bookId: 'b1'),
          const Failure<BookDetailsEntity, BookFailure>(
            BookDetailsLoadFailure(),
          ),
        );

        stubDetails(const Success(SupabaseResponse()));
        expect(
          await repository.getBookDetails(bookId: 'b1'),
          const Failure<BookDetailsEntity, BookFailure>(
            BookDetailsLoadFailure(),
          ),
        );
      },
    );
  });

  group('setReadingStatus', () {
    void stubStatus(
      Result<SupabaseResponse<ReadingStatus?>, SupabaseFailure> result,
    ) {
      when(
        () => service.invokeFunction<ReadingStatus?>(
          functionName: any(named: 'functionName'),
          body: any(named: 'body'),
          decoder: any(named: 'decoder'),
        ),
      ).thenAnswer((_) async => result);
    }

    test('sends READ and returns the saved status', () async {
      stubStatus(const Success(SupabaseResponse(data: ReadingStatus.read)));

      final result = await repository.setReadingStatus(
        bookId: 'b1',
        status: ReadingStatus.read,
      );

      expect(result.unwrap(), ReadingStatus.read);
      final call = verify(
        () => service.invokeFunction<ReadingStatus?>(
          functionName: 'set-book-reading-status',
          body: {'book_id': 'b1', 'status': 'READ'},
          decoder: captureAny(named: 'decoder'),
        ),
      )..called(1);

      final decoder = call.captured.single as ReadingStatus? Function(dynamic);
      expect(
        decoder({'book_id': 'b1', 'status': 'WANT_TO_READ'}),
        ReadingStatus.wantToRead,
      );
      expect(decoder({'book_id': 'b1', 'status': null}), isNull);
    });

    test('keeps the status key when clearing it', () async {
      stubStatus(const Success(SupabaseResponse()));

      await repository.setReadingStatus(bookId: 'b1', status: null);

      final body =
          verify(
                () => service.invokeFunction<ReadingStatus?>(
                  functionName: 'set-book-reading-status',
                  body: captureAny(named: 'body'),
                  decoder: any(named: 'decoder'),
                ),
              ).captured.single
              as Map<String, dynamic>;
      expect(body.containsKey('status'), isTrue);
      expect(body['status'], isNull);
    });

    test('maps a failure to ReadingStatusUpdateFailure', () async {
      stubStatus(
        const Failure(FunctionSupabaseFailure(message: 'x', code: '500')),
      );

      expect(
        await repository.setReadingStatus(bookId: 'b1', status: null),
        const Failure<ReadingStatus?, BookFailure>(
          ReadingStatusUpdateFailure(),
        ),
      );
    });
  });

  group('upsertReview', () {
    final saved = BookReviewResultEntity(
      review: MyBookReviewEntity(
        rating: 4,
        commentary: 'Bom',
        evaluatedAt: DateTime.utc(2026, 11, 7),
      ),
      ratingAverage: 4.5,
      ratingsCount: 3,
      myStatus: ReadingStatus.read,
    );

    void stubReview(
      Result<SupabaseResponse<BookReviewResultEntity>, SupabaseFailure> result,
    ) {
      when(
        () => service.invokeFunction<BookReviewResultEntity>(
          functionName: any(named: 'functionName'),
          body: any(named: 'body'),
          decoder: any(named: 'decoder'),
        ),
      ).thenAnswer((_) async => result);
    }

    test('sends rating and commentary', () async {
      stubReview(Success(SupabaseResponse(data: saved)));

      final result = await repository.upsertReview(
        bookId: 'b1',
        rating: 4,
        commentary: 'Bom',
      );

      expect(result.unwrap(), saved);
      verify(
        () => service.invokeFunction<BookReviewResultEntity>(
          functionName: 'upsert-book-review',
          body: {'book_id': 'b1', 'rating': 4, 'commentary': 'Bom'},
          decoder: any(named: 'decoder'),
        ),
      ).called(1);
    });

    test('maps a failure and empty data to BookReviewSaveFailure', () async {
      stubReview(
        const Failure(FunctionSupabaseFailure(message: 'x', code: '400')),
      );
      expect(
        await repository.upsertReview(bookId: 'b1', rating: 4),
        const Failure<BookReviewResultEntity, BookFailure>(
          BookReviewSaveFailure(),
        ),
      );

      stubReview(const Success(SupabaseResponse()));
      expect(
        await repository.upsertReview(bookId: 'b1', rating: 4),
        const Failure<BookReviewResultEntity, BookFailure>(
          BookReviewSaveFailure(),
        ),
      );
    });
  });
}
