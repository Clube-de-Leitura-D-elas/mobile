abstract final class BookRoutePaths {
  static const details = '/books/:bookId';

  static String detailsFor(String bookId) =>
      '/books/${Uri.encodeComponent(bookId)}';
}
