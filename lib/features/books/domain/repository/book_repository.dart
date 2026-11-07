import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/books/domain/entities/book_failure.dart';
import 'package:mobile/features/books/domain/entities/book_page.dart';
import 'package:mobile/features/books/domain/entities/book_reading_status.dart';

abstract class BookRepository {
  Future<Result<BookPage, BookFailure>> searchBooks({
    String? query,
    required int page,
  });

  Future<Result<BookReadingStatus?, BookFailure>> setReadingStatus({
    required String bookId,
    required BookReadingStatus? status,
  });
}
