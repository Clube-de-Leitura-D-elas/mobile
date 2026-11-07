import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/books/domain/entities/book_reading_status.dart';

void main() {
  test('reads the wire values from search-books', () {
    expect(bookReadingStatusFromWire('READ'), BookReadingStatus.read);
    expect(
      bookReadingStatusFromWire('WANT_TO_READ'),
      BookReadingStatus.wantToRead,
    );
    expect(bookReadingStatusFromWire(null), isNull);
  });

  test('rejects an unknown status', () {
    expect(() => bookReadingStatusFromWire('READING'), throwsFormatException);
  });

  test('writes the wire values for set-book-reading-status', () {
    expect(bookReadingStatusToWire(BookReadingStatus.read), 'READ');
    expect(
      bookReadingStatusToWire(BookReadingStatus.wantToRead),
      'WANT_TO_READ',
    );
    expect(bookReadingStatusToWire(null), isNull);
  });

  test('cycles absent, want to read, read, absent', () {
    expect(nextListReadingStatus(null), BookReadingStatus.wantToRead);
    expect(
      nextListReadingStatus(BookReadingStatus.wantToRead),
      BookReadingStatus.read,
    );
    expect(nextListReadingStatus(BookReadingStatus.read), isNull);
  });
}
