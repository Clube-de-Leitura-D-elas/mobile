import 'package:mobile/features/books/domain/entities/book_reading_status.dart';

BookReadingStatus? bookReadingStatusFromWire(Object? value) {
  return switch (value) {
    null => null,
    'READ' => BookReadingStatus.read,
    'WANT_TO_READ' => BookReadingStatus.wantToRead,
    _ => throw FormatException('Invalid reading status: $value'),
  };
}

String? bookReadingStatusToWire(BookReadingStatus? status) {
  return switch (status) {
    null => null,
    BookReadingStatus.read => 'READ',
    BookReadingStatus.wantToRead => 'WANT_TO_READ',
  };
}
