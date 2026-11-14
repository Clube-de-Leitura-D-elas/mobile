import 'package:flutter/foundation.dart';
import 'package:mobile/core/supabase/supabase_failure.dart';
import 'package:mobile/core/supabase/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/books/data/models/book_details_model.dart';
import 'package:mobile/features/books/data/models/book_page_model.dart';
import 'package:mobile/features/books/data/models/book_reading_status_model.dart';
import 'package:mobile/features/books/domain/entities/book_details_entity.dart';
import 'package:mobile/features/books/domain/entities/book_failure.dart';
import 'package:mobile/features/books/domain/entities/book_page.dart';
import 'package:mobile/features/books/domain/entities/book_reading_status.dart';
import 'package:mobile/features/books/domain/repository/book_repository.dart';

class BookRepositoryImpl implements BookRepository {
  BookRepositoryImpl({required this.supabaseService});

  final SupabaseService supabaseService;

  static const pageSize = 20;
  static const minQueryLength = 2;

  @override
  Future<Result<BookPage, BookFailure>> searchBooks({
    String? query,
    required int page,
  }) async {
    final trimmed = query?.trim() ?? '';
    final result = await supabaseService.invokeFunction<BookPageModel>(
      functionName: 'search-books',
      queryParameters: {
        'page': '$page',
        'pageSize': '$pageSize',
        if (trimmed.length >= minQueryLength) 'q': trimmed,
      },
      method: HttpMethod.get,
      decoder: BookPageModel.fromJson,
    );

    switch (result) {
      case Failure(:final failure):
        return Failure(_failureFrom(failure, const BookSearchFailure()));
      case Success(:final data):
        final pageData = data.data;
        if (pageData == null) {
          return const Failure(BookSearchFailure());
        }
        return Success(pageData.toDomain());
    }
  }

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
        return Failure(switch (failure.kind) {
          // O 400 só vem de um bookId que não é UUID (link quebrado).
          SupabaseFailureKind.notFound ||
          SupabaseFailureKind.validation => const BookNotFoundFailure(),
          _ => _failureFrom(failure, const BookDetailsLoadFailure()),
        });
      case Success(:final data):
        final model = data.data;
        if (model == null) {
          return const Failure(BookDetailsLoadFailure());
        }
        return Success(model.toDomain());
    }
  }

  @override
  Future<Result<BookReadingStatus?, BookFailure>> setReadingStatus({
    required String bookId,
    required BookReadingStatus? status,
  }) async {
    final result = await supabaseService.invokeFunction<BookReadingStatus?>(
      functionName: 'set-book-reading-status',
      body: {'book_id': bookId, 'status': bookReadingStatusToWire(status)},
      decoder: (dynamic json) {
        if (json is! Map<String, dynamic>) {
          throw const FormatException('Invalid reading status response.');
        }
        return bookReadingStatusFromWire(json['status']);
      },
    );

    switch (result) {
      case Failure():
        return const Failure(BookStatusFailure());
      case Success(:final data):
        return Success(data.data);
    }
  }

  @override
  Future<Result<void, BookFailure>> upsertBookReview({
    required String bookId,
    required int rating,
    required String? commentary,
  }) async {
    final result = await supabaseService.invokeFunction<void>(
      functionName: 'upsert-book-review',
      body: {'book_id': bookId, 'rating': rating, 'commentary': commentary},
    );

    switch (result) {
      case Failure(:final failure):
        return Failure(_failureFrom(failure, const BookReviewFailure()));
      case Success():
        return const Success(null);
    }
  }

  BookFailure _failureFrom(SupabaseFailure failure, BookFailure fallback) {
    debugPrint('[BookFailure] ${failure.message} (${failure.code})');
    return switch (failure.kind) {
      SupabaseFailureKind.network => const BookNetworkFailure(),
      SupabaseFailureKind.unauthorized => const BookSessionExpiredFailure(),
      _ => fallback,
    };
  }
}
