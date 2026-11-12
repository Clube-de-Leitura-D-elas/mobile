import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/books/domain/entities/book_failure.dart';
import 'package:mobile/features/books/domain/entities/rated_book.dart';
import 'package:mobile/features/books/domain/repository/book_repository.dart';
import 'package:mobile/features/books/presentation/cubit/rated_books_cubit.dart';
import 'package:mobile/features/books/presentation/cubit/rated_books_state.dart';
import 'package:mocktail/mocktail.dart';

class MockBookRepository extends Mock implements BookRepository {}

void main() {
  late MockBookRepository mockRepository;

  setUp(() {
    mockRepository = MockBookRepository();
  });

  const tBook = RatedBook(
    id: 'rated-1',
    bookId: 'book-1',
    title: 'Harry Potter e a Pedra Filosofal',
    author: 'J. K. Rowling',
    rating: 4.5,
  );

  final tBooksPage1 = List.generate(
    10,
    (i) => RatedBook(
      id: 'rated-$i',
      bookId: 'book-$i',
      title: 'Livro $i',
      author: 'Autora $i',
      rating: 4.0,
    ),
  );

  final tBooksPage2 = List.generate(
    5,
    (i) => RatedBook(
      id: 'rated-${i + 10}',
      bookId: 'book-${i + 10}',
      title: 'Livro ${i + 10}',
      author: 'Autora ${i + 10}',
      rating: 5.0,
    ),
  );

  group('RatedBooksCubit', () {
    test('initial state is RatedBooksInitial', () {
      final cubit = RatedBooksCubit(bookRepository: mockRepository);
      expect(cubit.state, const RatedBooksInitial());
    });

    blocTest<RatedBooksCubit, RatedBooksState>(
      'emits [RatedBooksLoading, RatedBooksLoaded] on loadInitial success with books',
      build: () {
        when(
          () => mockRepository.getRatedBooks(page: 1, limit: 10),
        ).thenAnswer((_) async => const Success([tBook]));
        return RatedBooksCubit(bookRepository: mockRepository);
      },
      act: (cubit) => cubit.loadInitial(),
      expect: () => [
        const RatedBooksLoading(),
        const RatedBooksLoaded(
          books: [tBook],
          hasMore: false,
          isLoadingMore: false,
          currentPage: 1,
        ),
      ],
    );

    blocTest<RatedBooksCubit, RatedBooksState>(
      'emits [RatedBooksLoading, RatedBooksEmpty] on loadInitial success with empty list',
      build: () {
        when(
          () => mockRepository.getRatedBooks(page: 1, limit: 10),
        ).thenAnswer((_) async => const Success([]));
        return RatedBooksCubit(bookRepository: mockRepository);
      },
      act: (cubit) => cubit.loadInitial(),
      expect: () => [
        const RatedBooksLoading(),
        const RatedBooksEmpty(),
      ],
    );

    blocTest<RatedBooksCubit, RatedBooksState>(
      'emits [RatedBooksLoading, RatedBooksError] on loadInitial failure',
      build: () {
        when(
          () => mockRepository.getRatedBooks(page: 1, limit: 10),
        ).thenAnswer((_) async => const Failure(RatedBooksLoadFailure()));
        return RatedBooksCubit(bookRepository: mockRepository);
      },
      act: (cubit) => cubit.loadInitial(),
      expect: () => [
        const RatedBooksLoading(),
        const RatedBooksError(RatedBooksLoadFailure()),
      ],
    );

    blocTest<RatedBooksCubit, RatedBooksState>(
      'appends next page of books on loadMore',
      build: () {
        when(
          () => mockRepository.getRatedBooks(page: 2, limit: 10),
        ).thenAnswer((_) async => Success(tBooksPage2));
        return RatedBooksCubit(bookRepository: mockRepository);
      },
      seed: () => RatedBooksLoaded(
        books: tBooksPage1,
        hasMore: true,
        isLoadingMore: false,
        currentPage: 1,
      ),
      act: (cubit) => cubit.loadMore(),
      expect: () => [
        RatedBooksLoaded(
          books: tBooksPage1,
          hasMore: true,
          isLoadingMore: true,
          currentPage: 1,
        ),
        RatedBooksLoaded(
          books: [...tBooksPage1, ...tBooksPage2],
          hasMore: false,
          isLoadingMore: false,
          currentPage: 2,
        ),
      ],
    );

    blocTest<RatedBooksCubit, RatedBooksState>(
      'sets hasMore to false when loadMore returns empty list',
      build: () {
        when(
          () => mockRepository.getRatedBooks(page: 2, limit: 10),
        ).thenAnswer((_) async => const Success([]));
        return RatedBooksCubit(bookRepository: mockRepository);
      },
      seed: () => RatedBooksLoaded(
        books: tBooksPage1,
        hasMore: true,
        isLoadingMore: false,
        currentPage: 1,
      ),
      act: (cubit) => cubit.loadMore(),
      expect: () => [
        RatedBooksLoaded(
          books: tBooksPage1,
          hasMore: true,
          isLoadingMore: true,
          currentPage: 1,
        ),
        RatedBooksLoaded(
          books: tBooksPage1,
          hasMore: false,
          isLoadingMore: false,
          currentPage: 1,
        ),
      ],
    );

    blocTest<RatedBooksCubit, RatedBooksState>(
      'keeps current books and stops loadingMore on loadMore failure',
      build: () {
        when(
          () => mockRepository.getRatedBooks(page: 2, limit: 10),
        ).thenAnswer((_) async => const Failure(RatedBooksLoadFailure()));
        return RatedBooksCubit(bookRepository: mockRepository);
      },
      seed: () => RatedBooksLoaded(
        books: tBooksPage1,
        hasMore: true,
        isLoadingMore: false,
        currentPage: 1,
      ),
      act: (cubit) => cubit.loadMore(),
      expect: () => [
        RatedBooksLoaded(
          books: tBooksPage1,
          hasMore: true,
          isLoadingMore: true,
          currentPage: 1,
        ),
        RatedBooksLoaded(
          books: tBooksPage1,
          hasMore: true,
          isLoadingMore: false,
          currentPage: 1,
        ),
      ],
    );

    blocTest<RatedBooksCubit, RatedBooksState>(
      'ignores loadMore when already loading more or hasMore is false',
      build: () => RatedBooksCubit(bookRepository: mockRepository),
      seed: () => RatedBooksLoaded(
        books: tBooksPage1,
        hasMore: false,
        isLoadingMore: false,
        currentPage: 1,
      ),
      act: (cubit) => cubit.loadMore(),
      expect: () => [],
    );

    blocTest<RatedBooksCubit, RatedBooksState>(
      'calls loadInitial on refresh',
      build: () {
        when(
          () => mockRepository.getRatedBooks(page: 1, limit: 10),
        ).thenAnswer((_) async => const Success([tBook]));
        return RatedBooksCubit(bookRepository: mockRepository);
      },
      act: (cubit) => cubit.refresh(),
      expect: () => [
        const RatedBooksLoading(),
        const RatedBooksLoaded(
          books: [tBook],
          hasMore: false,
          isLoadingMore: false,
          currentPage: 1,
        ),
      ],
    );
  });
}
