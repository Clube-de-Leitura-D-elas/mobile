import 'package:equatable/equatable.dart';

sealed class BookFailure extends Equatable {
  const BookFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

class BookSearchFailure extends BookFailure {
  const BookSearchFailure({
    super.message = 'Não foi possível carregar os livros. Tente novamente.',
  });
}

class BookStatusFailure extends BookFailure {
  const BookStatusFailure({
    super.message = 'Não foi possível atualizar o status de leitura.',
  });
}

class BookDetailsLoadFailure extends BookFailure {
  const BookDetailsLoadFailure({
    super.message = 'Não foi possível carregar o livro.',
  });
}

class BookNotFoundFailure extends BookFailure {
  const BookNotFoundFailure({super.message = 'Livro não encontrado.'});
}
