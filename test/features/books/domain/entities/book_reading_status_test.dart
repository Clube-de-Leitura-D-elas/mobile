import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/books/domain/entities/book_reading_status.dart';

void main() {
  test('marcar como lido e quero ler passam para lido; lido desmarca', () {
    expect(nextReadingStatus(null), BookReadingStatus.read);
    expect(
      nextReadingStatus(BookReadingStatus.wantToRead),
      BookReadingStatus.read,
    );
    expect(nextReadingStatus(BookReadingStatus.read), isNull);
  });
}
