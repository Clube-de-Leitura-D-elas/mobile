import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/books/domain/entities/book_reading_status.dart';

void main() {
  test('cycles absent, want to read, read, absent', () {
    expect(nextListReadingStatus(null), BookReadingStatus.wantToRead);
    expect(
      nextListReadingStatus(BookReadingStatus.wantToRead),
      BookReadingStatus.read,
    );
    expect(nextListReadingStatus(BookReadingStatus.read), isNull);
  });
}
