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
          status: BookReadingStatus.read,
        ),
      ).thenAnswer((_) async => const Success(BookReadingStatus.read));
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
        books: [book.copyWithStatus(BookReadingStatus.read)],
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
          status: BookReadingStatus.read,
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
    'given a status changed on the details, when applied, then the chip follows',
    build: buildCubit,
    seed: () => const BookSearchState(books: [book], page: 1),
    act: (cubit) => cubit.applyReadingStatus(
      'book-1',
      BookReadingStatus.read,
      isWrite: true,
    ),
    expect: () => [
      BookSearchState(
        books: [book.copyWithStatus(BookReadingStatus.read)],
        page: 1,
      ),
    ],
  );

  blocTest<BookSearchCubit, BookSearchState>(
    'given a book on the shelf, when the details clear it, then the chip clears',
    build: buildCubit,
    seed: () => BookSearchState(
      books: [book.copyWithStatus(BookReadingStatus.read)],
      page: 1,
    ),
    act: (cubit) => cubit.applyReadingStatus('book-1', null, isWrite: true),
    expect: () => [
      const BookSearchState(books: [book], page: 1),
    ],
  );

  blocTest<BookSearchCubit, BookSearchState>(
    'given a chip write in flight, when the details change the status, then the late answer is ignored',
    build: () {
      when(
        () => repository.setReadingStatus(
          bookId: 'book-1',
          status: BookReadingStatus.read,
        ),
      ).thenAnswer((_) async {
        await Future<void>.delayed(Duration.zero);
        return const Success(BookReadingStatus.read);
      });
      return buildCubit();
    },
    seed: () => BookSearchState(
      books: [book.copyWithStatus(BookReadingStatus.wantToRead)],
      page: 1,
    ),
    act: (cubit) async {
      final write = cubit.toggleStatus('book-1');
      // Nos detalhes a leitora desmarca o livro antes de o chip responder.
      cubit.applyReadingStatus('book-1', null, isWrite: true);
      await write;
    },
    expect: () => [
      BookSearchState(
        books: [book.copyWithStatus(BookReadingStatus.wantToRead)],
        page: 1,
        updatingStatusIds: const ['book-1'],
      ),
      const BookSearchState(
        books: [book],
        page: 1,
        updatingStatusIds: ['book-1'],
      ),
      const BookSearchState(books: [book], page: 1),
    ],
  );

  group('statusSyncFor', () {
    void stubChipWrite() {
      when(
        () => repository.setReadingStatus(
          bookId: 'book-1',
          status: BookReadingStatus.read,
        ),
      ).thenAnswer((_) async {
        await Future<void>.delayed(Duration.zero);
        return const Success(BookReadingStatus.read);
      });
    }

    blocTest<BookSearchCubit, BookSearchState>(
      'given no chip write, when the details load, then the chip follows them',
      build: buildCubit,
      seed: () => const BookSearchState(books: [book], page: 1),
      act: (cubit) => cubit.statusSyncFor('book-1')(
        BookReadingStatus.wantToRead,
        isWrite: false,
      ),
      expect: () => [
        BookSearchState(
          books: [book.copyWithStatus(BookReadingStatus.wantToRead)],
          page: 1,
        ),
      ],
    );

    blocTest<BookSearchCubit, BookSearchState>(
      'given a chip write in flight, when the details load first, then the write answer wins',
      build: () {
        stubChipWrite();
        return buildCubit();
      },
      seed: () => const BookSearchState(books: [book], page: 1),
      act: (cubit) async {
        final write = cubit.toggleStatus('book-1');
        cubit.statusSyncFor('book-1')(
          BookReadingStatus.wantToRead,
          isWrite: false,
        );
        await write;
      },
      expect: () => [
        const BookSearchState(
          books: [book],
          page: 1,
          updatingStatusIds: ['book-1'],
        ),
        BookSearchState(
          books: [book.copyWithStatus(BookReadingStatus.read)],
          page: 1,
        ),
      ],
    );

    void stubFailingChipWrite() {
      when(
        () => repository.setReadingStatus(
          bookId: 'book-1',
          status: BookReadingStatus.read,
        ),
      ).thenAnswer((_) async {
        await Future<void>.delayed(Duration.zero);
        return const Failure(BookStatusFailure());
      });
    }

    blocTest<BookSearchCubit, BookSearchState>(
      'given a load held during a chip write, when the write fails, then the load is applied',
      build: () {
        stubFailingChipWrite();
        return buildCubit();
      },
      seed: () => const BookSearchState(books: [book], page: 1),
      act: (cubit) async {
        final write = cubit.toggleStatus('book-1');
        cubit.statusSyncFor('book-1')(
          BookReadingStatus.wantToRead,
          isWrite: false,
        );
        await write;
      },
      expect: () => [
        const BookSearchState(
          books: [book],
          page: 1,
          updatingStatusIds: ['book-1'],
        ),
        BookSearchState(
          books: [book.copyWithStatus(BookReadingStatus.wantToRead)],
          page: 1,
          hasStatusError: true,
        ),
      ],
    );

    blocTest<BookSearchCubit, BookSearchState>(
      'given a held load, when the details write later and the chip fails, then the details write stays',
      build: () {
        stubFailingChipWrite();
        return buildCubit();
      },
      seed: () => const BookSearchState(books: [book], page: 1),
      act: (cubit) async {
        final write = cubit.toggleStatus('book-1');
        final sync = cubit.statusSyncFor('book-1');
        sync(BookReadingStatus.wantToRead, isWrite: false);
        sync(null, isWrite: true);
        await write;
      },
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
      'given a chip write confirmed after opening, when the old load arrives, then it is ignored',
      build: () {
        stubChipWrite();
        return buildCubit();
      },
      seed: () => const BookSearchState(books: [book], page: 1),
      act: (cubit) async {
        final write = cubit.toggleStatus('book-1');
        final sync = cubit.statusSyncFor('book-1');
        await write;
        sync(BookReadingStatus.wantToRead, isWrite: false);
      },
      expect: () => [
        const BookSearchState(
          books: [book],
          page: 1,
          updatingStatusIds: ['book-1'],
        ),
        BookSearchState(
          books: [book.copyWithStatus(BookReadingStatus.read)],
          page: 1,
        ),
      ],
    );

    blocTest<BookSearchCubit, BookSearchState>(
      'given a chip write in flight, when the details write the status the list shows, then the late answer is ignored',
      build: () {
        when(
          () => repository.setReadingStatus(bookId: 'book-1', status: null),
        ).thenAnswer((_) async {
          await Future<void>.delayed(Duration.zero);
          return const Success(null);
        });
        return buildCubit();
      },
      seed: () => BookSearchState(
        books: [book.copyWithStatus(BookReadingStatus.read)],
        page: 1,
      ),
      act: (cubit) async {
        final write = cubit.toggleStatus('book-1');
        cubit.statusSyncFor('book-1')(BookReadingStatus.read, isWrite: true);
        await write;
      },
      expect: () => [
        BookSearchState(
          books: [book.copyWithStatus(BookReadingStatus.read)],
          page: 1,
          updatingStatusIds: const ['book-1'],
        ),
        BookSearchState(
          books: [book.copyWithStatus(BookReadingStatus.read)],
          page: 1,
        ),
      ],
    );

    blocTest<BookSearchCubit, BookSearchState>(
      'given a chip write confirmed after opening, when the details write, then the details win',
      build: () {
        stubChipWrite();
        return buildCubit();
      },
      seed: () => const BookSearchState(books: [book], page: 1),
      act: (cubit) async {
        final write = cubit.toggleStatus('book-1');
        final sync = cubit.statusSyncFor('book-1');
        await write;
        sync(null, isWrite: true);
      },
      skip: 2,
      expect: () => [
        const BookSearchState(books: [book], page: 1),
      ],
    );
  });

  blocTest<BookSearchCubit, BookSearchState>(
    'given the same status or another book, when applied, then nothing changes',
    build: buildCubit,
    seed: () => const BookSearchState(books: [book], page: 1),
    act: (cubit) => cubit
      ..applyReadingStatus('book-1', null, isWrite: true)
      ..applyReadingStatus('other', BookReadingStatus.read, isWrite: true),
    expect: () => <BookSearchState>[],
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
          status: BookReadingStatus.read,
        ),
      ).thenAnswer((_) => gate.future);
      when(
        () => repository.searchBooks(query: 'harry', page: 1),
      ).thenAnswer((_) async => Success(page()));
      addTearDown(() {
        if (!gate.isCompleted) {
          gate.complete(const Success(BookReadingStatus.read));
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
          status: BookReadingStatus.read,
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
