import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/books/data/models/book_page_model.dart';
import 'package:mobile/features/books/domain/entities/book_page.dart';
import 'package:mobile/features/books/domain/entities/book_reading_status.dart';
import 'package:mobile/features/books/domain/entities/book_summary.dart';

void main() {
  test('parses a search-books page', () {
    final page = BookPageModel.fromJson({
      'items': [
        {
          'id': 'book-1',
          'title': 'Harry Potter e a Pedra Filosofal',
          'author': 'J. K. Rowling',
          'genre': 'Fantasia',
          'cover_url': 'https://example.com/capa.jpg',
          'my_status': 'READ',
        },
        {
          'id': 'book-2',
          'title': 'Outro',
          'author': '',
          'genre': '',
          'cover_url': null,
          'my_status': null,
        },
      ],
      'page': 1,
      'page_size': 20,
      'has_more': true,
    }).toDomain();

    expect(
      page,
      const BookPage(
        items: [
          BookSummary(
            id: 'book-1',
            title: 'Harry Potter e a Pedra Filosofal',
            author: 'J. K. Rowling',
            genre: 'Fantasia',
            coverUrl: 'https://example.com/capa.jpg',
            myStatus: BookReadingStatus.read,
          ),
          BookSummary(
            id: 'book-2',
            title: 'Outro',
            author: '',
            genre: '',
            coverUrl: null,
            myStatus: null,
          ),
        ],
        page: 1,
        pageSize: 20,
        hasMore: true,
      ),
    );
  });

  test('rejects a page without items', () {
    expect(() => BookPageModel.fromJson({'page': 1}), throwsFormatException);
  });
}
