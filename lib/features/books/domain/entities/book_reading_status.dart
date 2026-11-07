enum BookReadingStatus { read, wantToRead }

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

/// Toque no chip da lista: ausente → quero ler → já lido → ausente.
BookReadingStatus? nextListReadingStatus(BookReadingStatus? current) {
  return switch (current) {
    null => BookReadingStatus.wantToRead,
    BookReadingStatus.wantToRead => BookReadingStatus.read,
    BookReadingStatus.read => null,
  };
}
