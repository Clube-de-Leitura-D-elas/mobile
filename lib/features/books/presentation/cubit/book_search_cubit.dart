import 'package:bloc/bloc.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/books/domain/entities/book_reading_status.dart';
import 'package:mobile/features/books/domain/entities/book_summary.dart';
import 'package:mobile/features/books/domain/repository/book_repository.dart';
import 'package:mobile/features/books/presentation/cubit/book_search_state.dart';

class BookSearchCubit extends Cubit<BookSearchState> {
  BookSearchCubit({required this.bookRepository})
    : super(const BookSearchState());

  final BookRepository bookRepository;

  static const minQueryLength = 2;

  int _request = 0;

  // Mudanças de status vindas dos detalhes, por livro. A resposta de um toque
  // no chip que começou antes de uma delas está velha e não pode sobrescrever.
  final Map<String, int> _externalStatusChanges = {};

  // Gravações do chip já confirmadas, por livro. Um carregamento dos detalhes
  // aberto antes de uma delas pode ter lido o status antigo.
  final Map<String, int> _confirmedChipWrites = {};

  // Leitura dos detalhes que chegou com o chip gravando, por livro. Se a
  // gravação falhar, ela volta a ser o status mais novo que a lista conhece.
  final Map<String, BookReadingStatus?> _heldDetailsLoads = {};

  Future<void> load() => search('');

  Future<void> search(String raw) {
    final trimmed = raw.trim();
    final popular = trimmed.length < minQueryLength;
    final mode = popular ? BookSearchMode.popular : BookSearchMode.results;
    final query = popular ? '' : trimmed;
    if (mode == state.mode &&
        query == state.query &&
        !state.hasError &&
        state.page > 0) {
      return Future<void>.value();
    }
    final request = ++_request;
    emit(
      BookSearchState(
        mode: mode,
        query: query,
        isLoading: true,
        updatingStatusIds: state.updatingStatusIds,
      ),
    );
    return _fetch(request: request, page: 1, append: false);
  }

  Future<void> retry() {
    if (state.books.isEmpty) {
      return search(state.query);
    }
    return loadMore();
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading || state.isLoadingMore) {
      return;
    }
    final request = _request;
    emit(state.copyWith(isLoadingMore: true, hasLoadMoreError: false));
    await _fetch(request: request, page: state.page + 1, append: true);
  }

  Future<void> toggleStatus(String bookId) async {
    if (state.updatingStatusIds.contains(bookId)) {
      return;
    }
    BookSummary? current;
    for (final book in state.books) {
      if (book.id == bookId) {
        current = book;
      }
    }
    if (current == null) {
      return;
    }

    final changesAtStart = _externalStatusChanges[bookId] ?? 0;
    emit(
      state.copyWith(
        updatingStatusIds: [...state.updatingStatusIds, bookId],
        hasStatusError: false,
      ),
    );

    final result = await bookRepository.setReadingStatus(
      bookId: bookId,
      status: nextListReadingStatus(current.myStatus),
    );
    if (isClosed) {
      return;
    }

    final stillUpdating = [
      for (final id in state.updatingStatusIds)
        if (id != bookId) id,
    ];

    final hasHeldLoad = _heldDetailsLoads.containsKey(bookId);
    final heldLoad = _heldDetailsLoads.remove(bookId);

    switch (result) {
      case Failure():
        emit(
          state.copyWith(
            updatingStatusIds: stillUpdating,
            hasStatusError: true,
            books: hasHeldLoad
                ? [
                    for (final book in state.books)
                      book.id == bookId ? book.copyWithStatus(heldLoad) : book,
                  ]
                : null,
          ),
        );
      case Success(:final data):
        _confirmedChipWrites.update(
          bookId,
          (count) => count + 1,
          ifAbsent: () => 1,
        );
        final isStale = (_externalStatusChanges[bookId] ?? 0) != changesAtStart;
        emit(
          state.copyWith(
            updatingStatusIds: stillUpdating,
            books: isStale
                ? null
                : [
                    for (final book in state.books)
                      book.id == bookId ? book.copyWithStatus(data) : book,
                  ],
          ),
        );
    }
  }

  /// Callback para os detalhes do livro avisarem o status ao voltar. O
  /// carregamento (`isWrite: false`) não vale se o chip gravou desde a
  /// abertura; se o chip ainda está gravando, ele fica guardado para o caso de
  /// a gravação falhar.
  void Function(BookReadingStatus? status, {required bool isWrite})
  statusSyncFor(String bookId) {
    final confirmedAtOpen = _confirmedChipWrites[bookId] ?? 0;
    return (status, {required isWrite}) {
      final chipWroteSinceOpen =
          state.updatingStatusIds.contains(bookId) ||
          (_confirmedChipWrites[bookId] ?? 0) != confirmedAtOpen;
      if (!isWrite && chipWroteSinceOpen) {
        if (state.updatingStatusIds.contains(bookId)) {
          _heldDetailsLoads[bookId] = status;
        }
        return;
      }
      applyReadingStatus(bookId, status, isWrite: isWrite);
    };
  }

  /// Reflete na lista o status visto nos detalhes do livro. Só uma gravação
  /// feita lá ([isWrite]) invalida a resposta pendente de um toque no chip; o
  /// carregamento dos detalhes pode ter lido o backend antes dela terminar.
  void applyReadingStatus(
    String bookId,
    BookReadingStatus? status, {
    required bool isWrite,
  }) {
    if (isClosed) {
      return;
    }
    // Conta antes de comparar: mesmo igual ao que a lista mostra, uma gravação
    // nos detalhes é a mais recente e invalida a resposta pendente do chip.
    if (isWrite) {
      _heldDetailsLoads.remove(bookId);
      _externalStatusChanges.update(
        bookId,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
    }
    if (!state.books.any(
      (book) => book.id == bookId && book.myStatus != status,
    )) {
      return;
    }
    emit(
      state.copyWith(
        books: [
          for (final book in state.books)
            book.id == bookId ? book.copyWithStatus(status) : book,
        ],
      ),
    );
  }

  void clearStatusError() {
    if (!state.hasStatusError) {
      return;
    }
    emit(state.copyWith(hasStatusError: false));
  }

  Future<void> _fetch({
    required int request,
    required int page,
    required bool append,
  }) async {
    final query = state.mode == BookSearchMode.results ? state.query : null;
    final result = await bookRepository.searchBooks(query: query, page: page);
    if (isClosed || request != _request) {
      return;
    }

    switch (result) {
      case Failure(:final failure):
        emit(
          state.copyWith(
            isLoading: false,
            isLoadingMore: false,
            failure: failure,
            clearFailure: append,
            hasLoadMoreError: append,
          ),
        );
      case Success(:final data):
        emit(
          state.copyWith(
            books: append ? [...state.books, ...data.items] : data.items,
            page: data.page,
            hasMore: data.hasMore,
            isLoading: false,
            isLoadingMore: false,
            clearFailure: true,
            hasLoadMoreError: false,
          ),
        );
    }
  }
}
