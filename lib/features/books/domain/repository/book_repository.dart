import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/books/domain/entities/book_details_entity.dart';
import 'package:mobile/features/books/domain/entities/book_failure.dart';
import 'package:mobile/features/books/domain/entities/book_review_entity.dart';
import 'package:mobile/features/books/domain/entities/reading_status.dart';

abstract class BookRepository {
  static const int reviewsPageSize = 10;

  /// [reviewsPage] começa em 1 e pagina só as avaliações das outras leitoras.
  Future<Result<BookDetailsEntity, BookFailure>> getBookDetails({
    required String bookId,
    int reviewsPage = 1,
  });

  /// `null` tira o livro da estante.
  Future<Result<ReadingStatus?, BookFailure>> setReadingStatus({
    required String bookId,
    required ReadingStatus? status,
  });

  Future<Result<BookReviewResultEntity, BookFailure>> upsertReview({
    required String bookId,
    required int rating,
    String? commentary,
  });
}
