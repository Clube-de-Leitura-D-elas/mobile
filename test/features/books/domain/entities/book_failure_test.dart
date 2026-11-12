import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/books/domain/entities/book_failure.dart';

void main() {
  test('exposes the default messages used to compare failures', () {
    expect(const BookSearchFailure().props, [
      'Não foi possível carregar os livros. Tente novamente.',
    ]);
    expect(const BookStatusFailure().props, [
      'Não foi possível atualizar o status de leitura.',
    ]);
  });

  test('keeps the details failures apart, with the text left to l10n', () {
    expect(const BookDetailsLoadFailure().message, isEmpty);
    expect(const BookNotFoundFailure().message, isEmpty);
    expect(
      const BookDetailsLoadFailure(),
      isNot(equals(const BookNotFoundFailure())),
    );
  });
}
