import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/books/data/models/book_summary_model.dart';

void main() {
  test('rejects a book with a numeric id or an invalid cover', () {
    expect(
      () => BookSummaryModel.fromJson(const {
        'id': 1,
        'title': 'Dom Casmurro',
        'author': 'Machado de Assis',
        'genre': 'Romance',
        'cover_url': null,
        'my_status': null,
      }),
      throwsFormatException,
    );
    expect(
      () => BookSummaryModel.fromJson(const {
        'id': 'book-1',
        'title': 'Dom Casmurro',
        'author': 'Machado de Assis',
        'genre': 'Romance',
        'cover_url': 1,
        'my_status': null,
      }),
      throwsFormatException,
    );
  });
}
