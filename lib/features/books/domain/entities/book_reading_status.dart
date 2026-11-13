enum BookReadingStatus { read, wantToRead }

/// Toque no chip de status, na busca e nos detalhes: "Marcar como lido" e
/// "Quero ler" passam para lido; "Já lido" tira o livro da estante.
BookReadingStatus? nextReadingStatus(BookReadingStatus? current) {
  return switch (current) {
    BookReadingStatus.read => null,
    null || BookReadingStatus.wantToRead => BookReadingStatus.read,
  };
}
