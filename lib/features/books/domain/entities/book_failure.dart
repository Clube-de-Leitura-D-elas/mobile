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
