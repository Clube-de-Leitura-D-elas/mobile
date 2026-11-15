abstract final class BookRoutePaths {
  static const details = '/books/:bookId';
  static const ratedBooks = '/books/rated';

  static String detailsFor(String bookId) =>
      '/books/${Uri.encodeComponent(bookId)}';
}
