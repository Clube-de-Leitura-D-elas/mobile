enum BookReadingStatus { read, wantToRead }

/// Toque no chip da lista: ausente → quero ler → já lido → ausente.
BookReadingStatus? nextListReadingStatus(BookReadingStatus? current) {
  return switch (current) {
    null => BookReadingStatus.wantToRead,
    BookReadingStatus.wantToRead => BookReadingStatus.read,
    BookReadingStatus.read => null,
  };
}
