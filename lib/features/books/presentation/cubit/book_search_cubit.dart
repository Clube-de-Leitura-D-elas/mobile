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

  Future<void> load() => search('');

  Future<void> search(String raw) {
    final trimmed = raw.trim();
    final popular = trimmed.length < minQueryLength;
    final request = ++_request;
    emit(
      BookSearchState(
        mode: popular ? BookSearchMode.popular : BookSearchMode.results,
        query: popular ? '' : trimmed,
        isLoading: true,
      ),
    );
    return _fetch(request: request, page: 1, append: false);
  }

  Future<void> retry() {
    if (state.books.isEmpty) return search(state.query);
    return loadMore();
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading || state.isLoadingMore) return;
    final request = _request;
    emit(state.copyWith(isLoadingMore: true, hasLoadMoreError: false));
    await _fetch(request: request, page: state.page + 1, append: true);
  }

  Future<void> toggleStatus(String bookId) async {
    if (state.updatingStatusIds.contains(bookId)) return;
    BookSummary? current;
    for (final book in state.books) {
      if (book.id == bookId) current = book;
    }
    if (current == null) return;

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
    if (isClosed) return;

    final stillUpdating = [
      for (final id in state.updatingStatusIds)
        if (id != bookId) id,
    ];

    switch (result) {
      case Failure():
        emit(
          state.copyWith(
            updatingStatusIds: stillUpdating,
            hasStatusError: true,
          ),
        );
      case Success(:final data):
        emit(
          state.copyWith(
            updatingStatusIds: stillUpdating,
            books: [
              for (final book in state.books)
                book.id == bookId ? book.copyWithStatus(data) : book,
            ],
          ),
        );
    }
  }

  void clearStatusError() {
    if (!state.hasStatusError) return;
    emit(state.copyWith(hasStatusError: false));
  }

  Future<void> _fetch({
    required int request,
    required int page,
    required bool append,
  }) async {
    final query = state.mode == BookSearchMode.results ? state.query : null;
    final result = await bookRepository.searchBooks(query: query, page: page);
    if (isClosed || request != _request) return;

    switch (result) {
      case Failure():
        emit(
          state.copyWith(
            isLoading: false,
            isLoadingMore: false,
            hasError: !append && state.books.isEmpty,
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
            hasError: false,
            hasLoadMoreError: false,
          ),
        );
    }
  }
}
