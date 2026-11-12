import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/books/domain/entities/book_failure.dart';
import 'package:mobile/features/books/domain/entities/book_page.dart';
import 'package:mobile/features/books/domain/entities/book_reading_status.dart';
import 'package:mobile/features/books/domain/entities/book_summary.dart';
import 'package:mobile/features/books/domain/repository/book_repository.dart';
import 'package:mobile/features/books/presentation/cubit/book_search_cubit.dart';
import 'package:mobile/features/books/presentation/cubit/book_search_state.dart';
import 'package:mocktail/mocktail.dart';

class MockBookRepository extends Mock implements BookRepository {}

void main() {
  late MockBookRepository repository;

  const book = BookSummary(
    id: 'book-1',
    title: 'Harry Potter e a Pedra Filosofal',
    author: 'J. K. Rowling',
    genre: 'Fantasia',
    coverUrl: null,
    myStatus: null,
  );

  BookPage page({
    List<BookSummary> items = const [book],
    int page = 1,
    bool hasMore = false,
  }) {
    return BookPage(items: items, page: page, pageSize: 20, hasMore: hasMore);
  }

  setUp(() {
    repository = MockBookRepository();
  });

  BookSearchCubit buildCubit() => BookSearchCubit(bookRepository: repository);

  blocTest<BookSearchCubit, BookSearchState>(
    'given no query, when loading, then shows popular books',
    build: () {
      when(
        () => repository.searchBooks(page: 1),
      ).thenAnswer((_) async => Success(page()));
      return buildCubit();
    },
    act: (cubit) => cubit.load(),
    expect: () => [
      const BookSearchState(isLoading: true),
      const BookSearchState(books: [book], page: 1),
    ],
  );

  blocTest<BookSearchCubit, BookSearchState>(
    'given one character, when searching, then still loads popular books',
    build: () {
      when(
        () => repository.searchBooks(page: 1),
      ).thenAnswer((_) async => Success(page()));
      return buildCubit();
    },
    act: (cubit) => cubit.search('h'),
    verify: (_) {
      verify(() => repository.searchBooks(page: 1)).called(1);
      verifyNever(() => repository.searchBooks(query: 'h', page: 1));
    },
  );

  blocTest<BookSearchCubit, BookSearchState>(
    'given a query, when searching, then replaces the list with results',
    build: () {
      when(
        () => repository.searchBooks(query: 'harry', page: 1),
      ).thenAnswer((_) async => Success(page(hasMore: true)));
      return buildCubit();
    },
    act: (cubit) => cubit.search('harry'),
    expect: () => [
      const BookSearchState(
        mode: BookSearchMode.results,
        query: 'harry',
        isLoading: true,
      ),
      const BookSearchState(
        mode: BookSearchMode.results,
        query: 'harry',
        books: [book],
        page: 1,
        hasMore: true,
      ),
    ],
  );

  blocTest<BookSearchCubit, BookSearchState>(
    'given the first page fails, when searching, then exposes that failure',
    build: () {
      when(
        () => repository.searchBooks(query: 'harry', page: 1),
      ).thenAnswer((_) async => const Failure(BookNetworkFailure()));
      return buildCubit();
    },
    act: (cubit) => cubit.search('harry'),
    expect: () => [
      const BookSearchState(
        mode: BookSearchMode.results,
        query: 'harry',
        isLoading: true,
      ),
      const BookSearchState(
        mode: BookSearchMode.results,
        query: 'harry',
        failure: BookNetworkFailure(),
      ),
    ],
  );

  blocTest<BookSearchCubit, BookSearchState>(
    'given another page, when loading more, then appends it',
    build: () {
      when(
        () => repository.searchBooks(query: 'harry', page: 1),
      ).thenAnswer((_) async => Success(page(hasMore: true)));
      when(() => repository.searchBooks(query: 'harry', page: 2)).thenAnswer(
        (_) async => Success(
          page(
            items: const [
              BookSummary(
                id: 'book-2',
                title: 'Câmara Secreta',
                author: 'J. K. Rowling',
                genre: 'Fantasia',
                coverUrl: null,
                myStatus: BookReadingStatus.read,
              ),
            ],
            page: 2,
          ),
        ),
      );
      return buildCubit();
    },
    seed: () => const BookSearchState(
      mode: BookSearchMode.results,
      query: 'harry',
      books: [book],
      page: 1,
      hasMore: true,
    ),
    act: (cubit) => cubit.loadMore(),
    expect: () => [
      const BookSearchState(
        mode: BookSearchMode.results,
        query: 'harry',
        books: [book],
        page: 1,
        hasMore: true,
        isLoadingMore: true,
      ),
      const BookSearchState(
        mode: BookSearchMode.results,
        query: 'harry',
        books: [
          book,
          BookSummary(
            id: 'book-2',
            title: 'Câmara Secreta',
            author: 'J. K. Rowling',
            genre: 'Fantasia',
            coverUrl: null,
            myStatus: BookReadingStatus.read,
          ),
        ],
        page: 2,
      ),
    ],
  );

  blocTest<BookSearchCubit, BookSearchState>(
    'given another page fails, when loading more, then keeps the list and flags only that error',
    build: () {
      when(
        () => repository.searchBooks(query: 'harry', page: 2),
      ).thenAnswer((_) async => const Failure(BookSearchFailure()));
      return buildCubit();
    },
    seed: () => const BookSearchState(
      mode: BookSearchMode.results,
      query: 'harry',
      books: [book],
      page: 1,
      hasMore: true,
      hasLoadMoreError: true,
    ),
    act: (cubit) => cubit.loadMore(),
    expect: () => [
      const BookSearchState(
        mode: BookSearchMode.results,
        query: 'harry',
        books: [book],
        page: 1,
        hasMore: true,
        isLoadingMore: true,
      ),
      const BookSearchState(
        mode: BookSearchMode.results,
        query: 'harry',
        books: [book],
        page: 1,
        hasMore: true,
        hasLoadMoreError: true,
      ),
    ],
  );

  blocTest<BookSearchCubit, BookSearchState>(
    'given an empty error, when retrying, then searches again',
    build: () {
      when(
        () => repository.searchBooks(query: 'harry', page: 1),
      ).thenAnswer((_) async => Success(page()));
      return buildCubit();
    },
    seed: () => const BookSearchState(
      mode: BookSearchMode.results,
      query: 'harry',
      failure: BookSearchFailure(),
    ),
    act: (cubit) => cubit.retry(),
    expect: () => [
      const BookSearchState(
        mode: BookSearchMode.results,
        query: 'harry',
        isLoading: true,
      ),
      const BookSearchState(
        mode: BookSearchMode.results,
        query: 'harry',
        books: [book],
        page: 1,
      ),
    ],
  );

  blocTest<BookSearchCubit, BookSearchState>(
    'given a failed extra page, when retrying, then loads that page',
    build: () {
      when(() => repository.searchBooks(query: 'harry', page: 2)).thenAnswer(
        (_) async => Success(
          page(
            items: const [
              BookSummary(
                id: 'book-2',
                title: 'Câmara Secreta',
                author: 'J. K. Rowling',
                genre: 'Fantasia',
                coverUrl: null,
                myStatus: null,
              ),
            ],
            page: 2,
          ),
        ),
      );
      return buildCubit();
    },
    seed: () => const BookSearchState(
      mode: BookSearchMode.results,
      query: 'harry',
      books: [book],
      page: 1,
      hasMore: true,
      hasLoadMoreError: true,
    ),
    act: (cubit) => cubit.retry(),
    expect: () => [
      const BookSearchState(
        mode: BookSearchMode.results,
        query: 'harry',
        books: [book],
        page: 1,
        hasMore: true,
        isLoadingMore: true,
      ),
      const BookSearchState(
        mode: BookSearchMode.results,
        query: 'harry',
        books: [
          book,
          BookSummary(
            id: 'book-2',
            title: 'Câmara Secreta',
            author: 'J. K. Rowling',
            genre: 'Fantasia',
            coverUrl: null,
            myStatus: null,
          ),
        ],
        page: 2,
      ),
    ],
    verify: (_) {
      verifyNever(() => repository.searchBooks(query: 'harry', page: 1));
    },
  );

  blocTest<BookSearchCubit, BookSearchState>(
    'given a chip tap, when the write succeeds, then stores the returned status',
    build: () {
      when(
        () => repository.setReadingStatus(
          bookId: 'book-1',
          status: BookReadingStatus.wantToRead,
        ),
      ).thenAnswer((_) async => const Success(BookReadingStatus.wantToRead));
      return buildCubit();
    },
    seed: () => const BookSearchState(books: [book], page: 1),
    act: (cubit) => cubit.toggleStatus('book-1'),
    expect: () => [
      const BookSearchState(
        books: [book],
        page: 1,
        updatingStatusIds: ['book-1'],
      ),
      BookSearchState(
        books: [book.copyWithStatus(BookReadingStatus.wantToRead)],
        page: 1,
      ),
    ],
  );

  blocTest<BookSearchCubit, BookSearchState>(
    'given a chip tap, when the write fails, then keeps the book and flags the error',
    build: () {
      when(
        () => repository.setReadingStatus(
          bookId: 'book-1',
          status: BookReadingStatus.wantToRead,
        ),
      ).thenAnswer((_) async => const Failure(BookStatusFailure()));
      return buildCubit();
    },
    seed: () => const BookSearchState(books: [book], page: 1),
    act: (cubit) => cubit.toggleStatus('book-1'),
    expect: () => [
      const BookSearchState(
        books: [book],
        page: 1,
        updatingStatusIds: ['book-1'],
      ),
      const BookSearchState(books: [book], page: 1, hasStatusError: true),
    ],
  );

  blocTest<BookSearchCubit, BookSearchState>(
    'given a status error, when it is cleared, then the flag drops',
    build: buildCubit,
    seed: () =>
        const BookSearchState(books: [book], page: 1, hasStatusError: true),
    act: (cubit) => cubit.clearStatusError(),
    expect: () => [
      const BookSearchState(books: [book], page: 1),
    ],
  );

  blocTest<BookSearchCubit, BookSearchState>(
    'given no status error, when clearing, then nothing is emitted',
    build: buildCubit,
    seed: () => const BookSearchState(books: [book], page: 1),
    act: (cubit) => cubit.clearStatusError(),
    expect: () => <BookSearchState>[],
  );

  blocTest<BookSearchCubit, BookSearchState>(
    'given popular books, when the query stays too short, then keeps the list',
    build: buildCubit,
    seed: () => const BookSearchState(books: [book], page: 1),
    act: (cubit) => cubit.search('a'),
    expect: () => <BookSearchState>[],
    verify: (_) {
      verifyNever(
        () => repository.searchBooks(
          query: any(named: 'query'),
          page: any(named: 'page'),
        ),
      );
    },
  );

  blocTest<BookSearchCubit, BookSearchState>(
    'given results, when the query only gains trailing space, then keeps the list',
    build: buildCubit,
    seed: () => const BookSearchState(
      mode: BookSearchMode.results,
      query: 'harry',
      books: [book],
      page: 1,
    ),
    act: (cubit) => cubit.search('harry '),
    expect: () => <BookSearchState>[],
    verify: (_) {
      verifyNever(
        () => repository.searchBooks(
          query: any(named: 'query'),
          page: any(named: 'page'),
        ),
      );
    },
  );

  blocTest<BookSearchCubit, BookSearchState>(
    'given the same query failed, when searching again, then loads it',
    build: () {
      when(
        () => repository.searchBooks(query: 'harry', page: 1),
      ).thenAnswer((_) async => Success(page()));
      return buildCubit();
    },
    seed: () => const BookSearchState(
      mode: BookSearchMode.results,
      query: 'harry',
      page: 1,
      failure: BookSearchFailure(),
    ),
    act: (cubit) => cubit.search('harry'),
    expect: () => [
      const BookSearchState(
        mode: BookSearchMode.results,
        query: 'harry',
        isLoading: true,
      ),
      const BookSearchState(
        mode: BookSearchMode.results,
        query: 'harry',
        books: [book],
        page: 1,
      ),
    ],
  );

  blocTest<BookSearchCubit, BookSearchState>(
    'given a write in flight, when the query changes, then the chip stays locked',
    build: () {
      final gate = Completer<Result<BookReadingStatus?, BookFailure>>();
      when(
        () => repository.setReadingStatus(
          bookId: 'book-1',
          status: BookReadingStatus.wantToRead,
        ),
      ).thenAnswer((_) => gate.future);
      when(
        () => repository.searchBooks(query: 'harry', page: 1),
      ).thenAnswer((_) async => Success(page()));
      addTearDown(() {
        if (!gate.isCompleted) {
          gate.complete(const Success(BookReadingStatus.wantToRead));
        }
      });
      return buildCubit();
    },
    seed: () => const BookSearchState(books: [book], page: 1),
    act: (cubit) async {
      unawaited(cubit.toggleStatus('book-1'));
      await cubit.search('harry');
      await cubit.toggleStatus('book-1');
    },
    expect: () => [
      const BookSearchState(
        books: [book],
        page: 1,
        updatingStatusIds: ['book-1'],
      ),
      const BookSearchState(
        mode: BookSearchMode.results,
        query: 'harry',
        isLoading: true,
        updatingStatusIds: ['book-1'],
      ),
      const BookSearchState(
        mode: BookSearchMode.results,
        query: 'harry',
        books: [book],
        page: 1,
        updatingStatusIds: ['book-1'],
      ),
    ],
    verify: (_) {
      verify(
        () => repository.setReadingStatus(
          bookId: 'book-1',
          status: BookReadingStatus.wantToRead,
        ),
      ).called(1);
    },
  );

  blocTest<BookSearchCubit, BookSearchState>(
    'given a slow popular load, when the query changes, then ignores the old page',
    build: () {
      when(() => repository.searchBooks(page: 1)).thenAnswer((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 30));
        return Success(page());
      });
      when(
        () => repository.searchBooks(query: 'harry', page: 1),
      ).thenAnswer((_) async => Success(page(hasMore: true)));
      return buildCubit();
    },
    act: (cubit) async {
      final pending = cubit.load();
      unawaited(cubit.search('harry'));
      await pending;
    },
    expect: () => [
      const BookSearchState(isLoading: true),
      const BookSearchState(
        mode: BookSearchMode.results,
        query: 'harry',
        isLoading: true,
      ),
      const BookSearchState(
        mode: BookSearchMode.results,
        query: 'harry',
        books: [book],
        page: 1,
        hasMore: true,
      ),
    ],
  );
}
