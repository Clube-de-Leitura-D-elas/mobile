import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/books/domain/entities/book_details_entity.dart';
import 'package:mobile/features/books/domain/entities/book_failure.dart';
import 'package:mobile/features/books/domain/entities/book_review_entity.dart';
import 'package:mobile/features/books/domain/entities/reading_status.dart';
import 'package:mobile/features/books/domain/repository/book_repository.dart';
import 'package:mobile/features/books/presentation/cubit/book_details_cubit.dart';
import 'package:mobile/features/books/presentation/cubit/book_details_state.dart';
import 'package:mocktail/mocktail.dart';

class MockBookRepository extends Mock implements BookRepository {}

BookReviewEntity _review(String id) => BookReviewEntity(
  id: id,
  userName: 'Leitora $id',
  rating: 4,
  evaluatedAt: DateTime.utc(2026, 11, 1),
);

BookDetailsEntity _details({
  ReadingStatus? status,
  List<BookReviewEntity>? reviews,
  bool hasMore = false,
}) => BookDetailsEntity(
  id: 'b1',
  title: 'Livro',
  author: 'Autora',
  genre: '',
  publisher: '',
  ratingsCount: 2,
  ratingAverage: 4,
  myStatus: status,
  reviews: reviews ?? [_review('r1')],
  hasMoreReviews: hasMore,
);

void main() {
  late MockBookRepository repository;

  setUpAll(() => registerFallbackValue(ReadingStatus.read));

  setUp(() {
    repository = MockBookRepository();
  });

  BookDetailsCubit build() => BookDetailsCubit(repository: repository);

  BookDetailsState loaded(BookDetailsEntity details) => BookDetailsState(
    status: BookDetailsStatus.loaded,
    details: details,
    reviews: details.reviews,
    reviewsPage: 1,
    hasMoreReviews: details.hasMoreReviews,
  );

  void stubPage(int page, BookDetailsEntity details) {
    when(
      () => repository.getBookDetails(bookId: 'b1', reviewsPage: page),
    ).thenAnswer((_) async => Success(details));
  }

  group('load', () {
    blocTest<BookDetailsCubit, BookDetailsState>(
      'emits the loaded book with its first reviews page',
      setUp: () => stubPage(1, _details(hasMore: true)),
      build: build,
      act: (cubit) => cubit.load('b1'),
      expect: () => [const BookDetailsState(), loaded(_details(hasMore: true))],
    );

    blocTest<BookDetailsCubit, BookDetailsState>(
      'emits notFound for a missing book',
      setUp: () => when(
        () => repository.getBookDetails(bookId: 'b1'),
      ).thenAnswer((_) async => const Failure(BookNotFoundFailure())),
      build: build,
      act: (cubit) => cubit.load('b1'),
      expect: () => [
        const BookDetailsState(),
        const BookDetailsState(status: BookDetailsStatus.notFound),
      ],
    );

    blocTest<BookDetailsCubit, BookDetailsState>(
      'emits error and loads the same book again on retry',
      setUp: () => when(
        () => repository.getBookDetails(bookId: 'b1'),
      ).thenAnswer((_) async => const Failure(BookDetailsLoadFailure())),
      build: build,
      act: (cubit) async {
        await cubit.load('b1');
        stubPage(1, _details());
        await cubit.retry();
      },
      expect: () => [
        const BookDetailsState(),
        const BookDetailsState(status: BookDetailsStatus.error),
        const BookDetailsState(),
        loaded(_details()),
      ],
    );
  });

  group('loadMoreReviews', () {
    final first = _details(hasMore: true);

    blocTest<BookDetailsCubit, BookDetailsState>(
      'appends the next page without repeating reviews',
      setUp: () {
        stubPage(1, first);
        stubPage(
          2,
          _details(reviews: [_review('r1'), _review('r2')], hasMore: false),
        );
      },
      build: build,
      act: (cubit) async {
        await cubit.load('b1');
        await cubit.loadMoreReviews();
      },
      skip: 2,
      expect: () => [
        loaded(first).copyWith(isLoadingMoreReviews: true),
        loaded(first).copyWith(
          reviews: [_review('r1'), _review('r2')],
          reviewsPage: 2,
          hasMoreReviews: false,
        ),
      ],
    );

    blocTest<BookDetailsCubit, BookDetailsState>(
      'flags the failure and clears it on retry',
      setUp: () {
        stubPage(1, first);
        when(
          () => repository.getBookDetails(bookId: 'b1', reviewsPage: 2),
        ).thenAnswer((_) async => const Failure(BookDetailsLoadFailure()));
      },
      build: build,
      act: (cubit) async {
        await cubit.load('b1');
        await cubit.loadMoreReviews();
        await cubit.loadMoreReviews();
      },
      skip: 2,
      expect: () => [
        loaded(first).copyWith(isLoadingMoreReviews: true),
        loaded(first).copyWith(loadMoreReviewsFailed: true),
        loaded(first).copyWith(isLoadingMoreReviews: true),
        loaded(first).copyWith(loadMoreReviewsFailed: true),
      ],
    );

    blocTest<BookDetailsCubit, BookDetailsState>(
      'does nothing without more reviews',
      seed: () => loaded(_details()),
      build: build,
      act: (cubit) => cubit.loadMoreReviews(),
      expect: () => <BookDetailsState>[],
    );
  });

  group('toggleReadingStatus', () {
    void stubStatus(
      ReadingStatus? sent,
      Result<ReadingStatus?, BookFailure> answer,
    ) {
      when(
        () => repository.setReadingStatus(bookId: 'b1', status: sent),
      ).thenAnswer((_) async => answer);
    }

    blocTest<BookDetailsCubit, BookDetailsState>(
      'marks an unshelved book as read',
      setUp: () =>
          stubStatus(ReadingStatus.read, const Success(ReadingStatus.read)),
      seed: () => loaded(_details()),
      build: build,
      act: (cubit) => cubit.toggleReadingStatus(),
      expect: () => [
        loaded(_details()).copyWith(isUpdatingStatus: true),
        loaded(
          _details(),
        ).copyWith(details: _details(status: ReadingStatus.read)),
      ],
    );

    blocTest<BookDetailsCubit, BookDetailsState>(
      'marks a want-to-read book as read',
      setUp: () =>
          stubStatus(ReadingStatus.read, const Success(ReadingStatus.read)),
      seed: () => loaded(_details(status: ReadingStatus.wantToRead)),
      build: build,
      act: (cubit) => cubit.toggleReadingStatus(),
      verify: (cubit) =>
          expect(cubit.state.details?.myStatus, ReadingStatus.read),
    );

    blocTest<BookDetailsCubit, BookDetailsState>(
      'takes a read book off the shelf',
      setUp: () => stubStatus(null, const Success(null)),
      seed: () => loaded(_details(status: ReadingStatus.read)),
      build: build,
      act: (cubit) => cubit.toggleReadingStatus(),
      verify: (cubit) {
        expect(cubit.state.details?.myStatus, isNull);
        expect(cubit.state.isUpdatingStatus, isFalse);
      },
    );

    blocTest<BookDetailsCubit, BookDetailsState>(
      'keeps the status and raises a notice on failure',
      setUp: () => stubStatus(
        ReadingStatus.read,
        const Failure(ReadingStatusUpdateFailure()),
      ),
      seed: () => loaded(_details()),
      build: build,
      act: (cubit) => cubit.toggleReadingStatus(),
      expect: () => [
        loaded(_details()).copyWith(isUpdatingStatus: true),
        loaded(
          _details(),
        ).copyWith(notice: BookDetailsNotice.readingStatusFailed),
      ],
    );

    blocTest<BookDetailsCubit, BookDetailsState>(
      'ignores a tap while the status is saving',
      seed: () => loaded(_details()).copyWith(isUpdatingStatus: true),
      build: build,
      act: (cubit) => cubit.toggleReadingStatus(),
      expect: () => <BookDetailsState>[],
      verify: (_) => verifyNever(
        () => repository.setReadingStatus(
          bookId: any(named: 'bookId'),
          status: any(named: 'status'),
        ),
      ),
    );
  });

  group('submitReview', () {
    final saved = BookReviewResultEntity(
      review: MyBookReviewEntity(
        rating: 5,
        commentary: 'Ótimo',
        evaluatedAt: DateTime.utc(2026, 11, 7),
      ),
      ratingAverage: 4.5,
      ratingsCount: 3,
      myStatus: ReadingStatus.read,
    );

    test('applies the saved review and marks the book as read', () async {
      when(
        () => repository.upsertReview(
          bookId: 'b1',
          rating: 5,
          commentary: 'Ótimo',
        ),
      ).thenAnswer((_) async => Success(saved));
      final cubit = build()..emit(loaded(_details()));
      addTearDown(cubit.close);

      final ok = await cubit.submitReview(rating: 5, commentary: 'Ótimo');

      expect(ok, isTrue);
      expect(cubit.state.details, _details().withReview(saved));
      expect(cubit.state.details?.myStatus, ReadingStatus.read);
    });

    test('reports a failure and keeps the book unchanged', () async {
      when(
        () => repository.upsertReview(bookId: 'b1', rating: 2),
      ).thenAnswer((_) async => const Failure(BookReviewSaveFailure()));
      final cubit = build()..emit(loaded(_details()));
      addTearDown(cubit.close);

      final ok = await cubit.submitReview(rating: 2);

      expect(ok, isFalse);
      expect(cubit.state, loaded(_details()));
    });
  });
}
