import 'package:mobile/features/books/domain/entities/book_failure.dart';
import 'package:mobile/l10n/app_localizations.dart';

/// Texto para a usuária quando a busca não carrega. Rede e sessão vêm do
/// l10n; o resto cai na mensagem genérica da busca.
String bookSearchFailureMessage(AppLocalizations l10n, BookFailure failure) =>
    switch (failure) {
      BookNetworkFailure() => l10n.errorNoConnection,
      BookSessionExpiredFailure() => l10n.errorSessionExpired,
      _ => l10n.bookSearchLoadError,
    };

/// Texto para a usuária quando os detalhes do livro não carregam.
String bookDetailsFailureMessage(AppLocalizations l10n, BookFailure? failure) =>
    switch (failure) {
      BookNetworkFailure() => l10n.errorNoConnection,
      BookSessionExpiredFailure() => l10n.errorSessionExpired,
      _ => l10n.bookDetailLoadError,
    };

/// Texto para a usuária quando os livros avaliados não carregam.
String ratedBooksFailureMessage(AppLocalizations l10n, BookFailure failure) =>
    switch (failure) {
      BookNetworkFailure() => l10n.errorNoConnection,
      BookSessionExpiredFailure() => l10n.errorSessionExpired,
      _ => l10n.ratedBooksLoadError,
    };
