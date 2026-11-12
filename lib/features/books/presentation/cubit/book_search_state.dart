import 'package:equatable/equatable.dart';
import 'package:mobile/features/books/domain/entities/book_failure.dart';
import 'package:mobile/features/books/domain/entities/book_summary.dart';

enum BookSearchMode { popular, results }

class BookSearchState extends Equatable {
  const BookSearchState({
    this.mode = BookSearchMode.popular,
    this.query = '',
    this.books = const [],
    this.page = 0,
    this.hasMore = false,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.failure,
    this.hasLoadMoreError = false,
    this.updatingStatusIds = const [],
    this.hasStatusError = false,
  });

  final BookSearchMode mode;
  final String query;
  final List<BookSummary> books;
  final int page;
  final bool hasMore;
  final bool isLoading;
  final bool isLoadingMore;

  /// Por que a primeira página não carregou.
  final BookFailure? failure;
  final bool hasLoadMoreError;
  final List<String> updatingStatusIds;
  final bool hasStatusError;

  bool get hasError => failure != null;

  bool get isEmpty => !isLoading && !hasError && books.isEmpty && page > 0;

  BookSearchState copyWith({
    BookSearchMode? mode,
    String? query,
    List<BookSummary>? books,
    int? page,
    bool? hasMore,
    bool? isLoading,
    bool? isLoadingMore,
    BookFailure? failure,
    bool clearFailure = false,
    bool? hasLoadMoreError,
    List<String>? updatingStatusIds,
    bool? hasStatusError,
  }) {
    return BookSearchState(
      mode: mode ?? this.mode,
      query: query ?? this.query,
      books: books ?? this.books,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      failure: clearFailure ? null : failure ?? this.failure,
      hasLoadMoreError: hasLoadMoreError ?? this.hasLoadMoreError,
      updatingStatusIds: updatingStatusIds ?? this.updatingStatusIds,
      hasStatusError: hasStatusError ?? this.hasStatusError,
    );
  }

  @override
  List<Object?> get props => [
    mode,
    query,
    books,
    page,
    hasMore,
    isLoading,
    isLoadingMore,
    failure,
    hasLoadMoreError,
    updatingStatusIds,
    hasStatusError,
  ];
}
