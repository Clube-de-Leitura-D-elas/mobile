import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/books/domain/entities/book_reading_status.dart';

void main() {
  test('no status and want to read move to read; read clears it', () {
    expect(nextReadingStatus(null), BookReadingStatus.read);
    expect(
      nextReadingStatus(BookReadingStatus.wantToRead),
      BookReadingStatus.read,
    );
    expect(nextReadingStatus(BookReadingStatus.read), isNull);
  });
}
