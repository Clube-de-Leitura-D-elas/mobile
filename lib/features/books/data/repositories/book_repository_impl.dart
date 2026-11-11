import 'package:mobile/core/supabase/supabase_service.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/books/data/models/book_details_model.dart';
import 'package:mobile/features/books/data/models/book_review_model.dart';
import 'package:mobile/features/books/data/models/reading_status_model.dart';
import 'package:mobile/features/books/domain/entities/book_details_entity.dart';
import 'package:mobile/features/books/domain/entities/book_failure.dart';
import 'package:mobile/features/books/domain/entities/book_review_entity.dart';
import 'package:mobile/features/books/domain/entities/reading_status.dart';
import 'package:mobile/features/books/domain/repository/book_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show HttpMethod;

class BookRepositoryImpl implements BookRepository {
  BookRepositoryImpl({required this.supabaseService});

  final SupabaseService supabaseService;

  @override
  Future<Result<BookDetailsEntity, BookFailure>> getBookDetails({
    required String bookId,
    int reviewsPage = 1,
  }) async {
    final result = await supabaseService.invokeFunction<BookDetailsModel>(
      functionName: 'get-book-details',
      // A function só aceita GET e lê tudo da query string.
      method: HttpMethod.get,
      queryParameters: {
        'bookId': bookId,
        'reviewsPage': '$reviewsPage',
        'reviewsPageSize': '${BookRepository.reviewsPageSize}',
      },
      decoder: (data) =>
          BookDetailsModel.fromJson(data as Map<String, dynamic>),
    );

    switch (result) {
      case Failure(:final failure):
        return Failure(
          failure.code == '404'
              ? const BookNotFoundFailure()
              : const BookDetailsLoadFailure(),
        );
      case Success(:final data):
        final model = data.data;
        if (model == null) return const Failure(BookDetailsLoadFailure());
        return Success(model.toDomain());
    }
  }

  @override
  Future<Result<ReadingStatus?, BookFailure>> setReadingStatus({
    required String bookId,
    required ReadingStatus? status,
  }) async {
    final result = await supabaseService.invokeFunction<ReadingStatus?>(
      functionName: 'set-book-reading-status',
      // A chave `status` vai mesmo nula: ausente a function recusa.
      body: {'book_id': bookId, 'status': ReadingStatusModel.toJson(status)},
      decoder: (data) =>
          ReadingStatusModel.fromJson((data as Map<String, dynamic>)['status']),
    );

    return switch (result) {
      Failure() => const Failure(ReadingStatusUpdateFailure()),
      Success(:final data) => Success(data.data),
    };
  }

  @override
  Future<Result<BookReviewResultEntity, BookFailure>> upsertReview({
    required String bookId,
    required int rating,
    String? commentary,
  }) async {
    final result = await supabaseService.invokeFunction<BookReviewResultEntity>(
      functionName: 'upsert-book-review',
      body: {'book_id': bookId, 'rating': rating, 'commentary': commentary},
      decoder: (data) =>
          BookReviewModel.resultFromJson(data as Map<String, dynamic>),
    );

    switch (result) {
      case Failure():
        return const Failure(BookReviewSaveFailure());
      case Success(:final data):
        final review = data.data;
        if (review == null) return const Failure(BookReviewSaveFailure());
        return Success(review);
    }
  }
}
