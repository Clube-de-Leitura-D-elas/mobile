import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/books/domain/entities/book_details_entity.dart';
import 'package:mobile/features/books/domain/entities/book_failure.dart';
import 'package:mobile/features/books/domain/entities/book_review_entity.dart';
import 'package:mobile/features/books/domain/entities/book_reading_status.dart';
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
  BookReadingStatus? status,
  MyBookReviewEntity? myReview,
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
  myReview: myReview,
  reviews: reviews ?? [_review('r1')],
  hasMoreReviews: hasMore,
);

void main() {
  late MockBookRepository repository;

  setUpAll(() => registerFallbackValue(BookReadingStatus.read));

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
      ).thenAnswer((_) async => const Failure(BookNetworkFailure())),
      build: build,
      act: (cubit) async {
        await cubit.load('b1');
        stubPage(1, _details());
        await cubit.retry();
      },
      expect: () => [
        const BookDetailsState(),
        const BookDetailsState(
          status: BookDetailsStatus.error,
          failure: BookNetworkFailure(),
        ),
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
      'flags the failure and recovers the page on retry',
      setUp: () {
        stubPage(1, first);
        final answers = <Result<BookDetailsEntity, BookFailure>>[
          const Failure(BookDetailsLoadFailure()),
          Success(_details(reviews: [_review('r2')], hasMore: false)),
        ];
        when(
          () => repository.getBookDetails(bookId: 'b1', reviewsPage: 2),
        ).thenAnswer((_) async => answers.removeAt(0));
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
        loaded(first).copyWith(
          reviews: [_review('r1'), _review('r2')],
          reviewsPage: 2,
          hasMoreReviews: false,
        ),
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
      BookReadingStatus? sent,
      Result<BookReadingStatus?, BookFailure> answer,
    ) {
      when(
        () => repository.setReadingStatus(bookId: 'b1', status: sent),
      ).thenAnswer((_) async => answer);
    }

    blocTest<BookDetailsCubit, BookDetailsState>(
      'marks an unshelved book as read',
      setUp: () => stubStatus(
        BookReadingStatus.read,
        const Success(BookReadingStatus.read),
      ),
      seed: () => loaded(_details()),
      build: build,
      act: (cubit) => cubit.toggleReadingStatus(),
      expect: () => [
        loaded(_details()).copyWith(isUpdatingStatus: true),
        loaded(
          _details(),
        ).copyWith(details: _details(status: BookReadingStatus.read)),
      ],
    );

    blocTest<BookDetailsCubit, BookDetailsState>(
      'marks a want-to-read book as read',
      setUp: () => stubStatus(
        BookReadingStatus.read,
        const Success(BookReadingStatus.read),
      ),
      seed: () => loaded(_details(status: BookReadingStatus.wantToRead)),
      build: build,
      act: (cubit) => cubit.toggleReadingStatus(),
      verify: (cubit) =>
          expect(cubit.state.details?.myStatus, BookReadingStatus.read),
    );

    blocTest<BookDetailsCubit, BookDetailsState>(
      'takes a read book off the shelf',
      setUp: () => stubStatus(null, const Success(null)),
      seed: () => loaded(_details(status: BookReadingStatus.read)),
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
        BookReadingStatus.read,
        const Failure(BookStatusFailure()),
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

  group('upsertBookReview', () {
    final review = MyBookReviewEntity(
      rating: 5,
      commentary: 'Muito bom',
      evaluatedAt: DateTime.utc(2026, 11, 14),
    );

    blocTest<BookDetailsCubit, BookDetailsState>(
      'saves, reloads the detail and marks the book as read',
      setUp: () {
        when(
          () => repository.upsertBookReview(
            bookId: 'b1',
            rating: 5,
            commentary: 'Muito bom',
          ),
        ).thenAnswer((_) async => const Success(null));
        when(() => repository.getBookDetails(bookId: 'b1')).thenAnswer(
          (_) async => Success(
            _details(myReview: review, status: BookReadingStatus.read),
          ),
        );
      },
      seed: () => loaded(_details()),
      build: build,
      act: (cubit) =>
          cubit.upsertBookReview(rating: 5, commentary: 'Muito bom'),
      expect: () => [
        loaded(_details()).copyWith(isSubmittingReview: true),
        BookDetailsState(
          status: BookDetailsStatus.loaded,
          details: _details(myReview: review, status: BookReadingStatus.read),
          reviews: _details(
            myReview: review,
            status: BookReadingStatus.read,
          ).reviews,
          reviewsPage: 1,
          hasMoreReviews: false,
          notice: BookDetailsNotice.reviewSaved,
        ),
      ],
    );

    blocTest<BookDetailsCubit, BookDetailsState>(
      'emits an error notice and keeps the detail when saving fails',
      setUp: () => when(
        () => repository.upsertBookReview(
          bookId: 'b1',
          rating: 3,
          commentary: null,
        ),
      ).thenAnswer((_) async => const Failure(BookReviewFailure())),
      seed: () => loaded(_details()),
      build: build,
      act: (cubit) => cubit.upsertBookReview(rating: 3, commentary: null),
      expect: () => [
        loaded(_details()).copyWith(isSubmittingReview: true),
        loaded(_details()).copyWith(
          isSubmittingReview: false,
          notice: BookDetailsNotice.reviewFailed,
        ),
      ],
      verify: (_) => verifyNever(() => repository.getBookDetails(bookId: 'b1')),
    );

    blocTest<BookDetailsCubit, BookDetailsState>(
      'keeps the review modal open when refreshing after save fails',
      setUp: () {
        when(
          () => repository.upsertBookReview(
            bookId: 'b1',
            rating: 4,
            commentary: 'Comentário',
          ),
        ).thenAnswer((_) async => const Success(null));
        when(
          () => repository.getBookDetails(bookId: 'b1'),
        ).thenAnswer((_) async => const Failure(BookDetailsLoadFailure()));
      },
      seed: () => loaded(_details()),
      build: build,
      act: (cubit) =>
          cubit.upsertBookReview(rating: 4, commentary: 'Comentário'),
      expect: () => [
        loaded(_details()).copyWith(isSubmittingReview: true),
        loaded(_details()).copyWith(
          isSubmittingReview: false,
          notice: BookDetailsNotice.reviewFailed,
        ),
      ],
    );

    blocTest<BookDetailsCubit, BookDetailsState>(
      'does not submit while another review is being submitted',
      setUp: () => when(
        () => repository.upsertBookReview(
          bookId: any(named: 'bookId'),
          rating: any(named: 'rating'),
          commentary: any(named: 'commentary'),
        ),
      ).thenAnswer((_) async => const Success(null)),
      seed: () => loaded(_details()).copyWith(isSubmittingReview: true),
      build: build,
      act: (cubit) => cubit.upsertBookReview(rating: 5, commentary: null),
      expect: () => <BookDetailsState>[],
      verify: (_) => verifyNever(
        () => repository.upsertBookReview(
          bookId: any(named: 'bookId'),
          rating: any(named: 'rating'),
          commentary: any(named: 'commentary'),
        ),
      ),
    );
  });
}
