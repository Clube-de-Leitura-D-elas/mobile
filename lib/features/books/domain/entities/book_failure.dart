import 'package:equatable/equatable.dart';

sealed class BookFailure extends Equatable {
  const BookFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Sem conexão. O texto vem do l10n, na apresentação.
class BookNetworkFailure extends BookFailure {
  const BookNetworkFailure() : super(message: '');
}

/// Sessão expirada (HTTP 401). O texto vem do l10n, na apresentação.
class BookSessionExpiredFailure extends BookFailure {
  const BookSessionExpiredFailure() : super(message: '');
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

class BookReviewFailure extends BookFailure {
  const BookReviewFailure({
    super.message = 'Não foi possível salvar sua avaliação.',
  });
}

/// Falha genérica ao abrir os detalhes. O texto vem do l10n, na apresentação.
class BookDetailsLoadFailure extends BookFailure {
  const BookDetailsLoadFailure() : super(message: '');
}

/// Livro inexistente (404) ou id inválido (400). O texto vem do l10n.
class BookNotFoundFailure extends BookFailure {
  const BookNotFoundFailure() : super(message: '');
}
