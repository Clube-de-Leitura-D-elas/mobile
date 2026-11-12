import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/books/domain/entities/book_details_entity.dart';
import 'package:mobile/features/books/domain/entities/book_failure.dart';
import 'package:mobile/features/books/domain/entities/book_page.dart';
import 'package:mobile/features/books/domain/entities/book_reading_status.dart';
import 'package:mobile/features/books/domain/entities/book_review_entity.dart';

abstract class BookRepository {
  static const int reviewsPageSize = 10;

  Future<Result<BookPage, BookFailure>> searchBooks({
    String? query,
    required int page,
  });

  /// [reviewsPage] começa em 1 e pagina só as avaliações das outras leitoras.
  Future<Result<BookDetailsEntity, BookFailure>> getBookDetails({
    required String bookId,
    int reviewsPage = 1,
  });

  /// `null` tira o livro da estante.
  Future<Result<BookReadingStatus?, BookFailure>> setReadingStatus({
    required String bookId,
    required BookReadingStatus? status,
  });

  Future<Result<BookReviewResultEntity, BookFailure>> upsertReview({
    required String bookId,
    required int rating,
    String? commentary,
  });
}
