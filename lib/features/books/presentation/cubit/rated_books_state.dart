import 'package:equatable/equatable.dart';
import 'package:mobile/features/books/domain/entities/book_failure.dart';
import 'package:mobile/features/books/domain/entities/rated_book.dart';

sealed class RatedBooksState extends Equatable {
  const RatedBooksState();

  @override
  List<Object?> get props => [];
}

class RatedBooksInitial extends RatedBooksState {
  const RatedBooksInitial();
}

class RatedBooksLoading extends RatedBooksState {
  const RatedBooksLoading();
}

class RatedBooksEmpty extends RatedBooksState {
  const RatedBooksEmpty();
}

class RatedBooksError extends RatedBooksState {
  final BookFailure failure;

  const RatedBooksError(this.failure);

  @override
  List<Object?> get props => [failure];
}

class RatedBooksLoaded extends RatedBooksState {
  final List<RatedBook> books;
  final bool hasMore;
  final bool isLoadingMore;
  final int currentPage;
  final BookFailure? loadMoreFailure;

  const RatedBooksLoaded({
    required this.books,
    required this.hasMore,
    this.isLoadingMore = false,
    required this.currentPage,
    this.loadMoreFailure,
  });

  RatedBooksLoaded copyWith({
    List<RatedBook>? books,
    bool? hasMore,
    bool? isLoadingMore,
    int? currentPage,
    BookFailure? loadMoreFailure,
    bool clearLoadMoreFailure = false,
  }) {
    return RatedBooksLoaded(
      books: books ?? this.books,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      currentPage: currentPage ?? this.currentPage,
      loadMoreFailure: clearLoadMoreFailure
          ? null
          : (loadMoreFailure ?? this.loadMoreFailure),
    );
  }

  @override
  List<Object?> get props => [
    books,
    hasMore,
    isLoadingMore,
    currentPage,
    loadMoreFailure,
  ];
}
