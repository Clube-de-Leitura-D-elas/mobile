import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mobile/core/supabase/supabase_failure.dart';
import 'package:mobile/core/supabase/supabase_response.dart';
import 'package:mobile/core/supabase/supabase_service.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/books/data/datasources/rated_books_remote_data_source.dart';
import 'package:mobile/features/books/data/models/book_details_model.dart';
import 'package:mobile/features/books/data/models/book_page_model.dart';
import 'package:mobile/features/books/data/models/book_recommendation_group_model.dart';
import 'package:mobile/features/books/data/models/rated_book_model.dart';
import 'package:mobile/features/books/data/repositories/book_repository_impl.dart';
import 'package:mobile/features/books/domain/entities/book_details_entity.dart';
import 'package:mobile/features/books/domain/entities/book_failure.dart';
import 'package:mobile/features/books/domain/entities/book_page.dart';
import 'package:mobile/features/books/domain/entities/book_reading_status.dart';
import 'package:mobile/features/books/domain/entities/book_recommendation_group.dart';
import 'package:mobile/features/books/domain/entities/book_recommendation_outcome.dart';
import 'package:mobile/features/books/domain/entities/rated_book.dart';
import 'package:mobile/features/books/domain/repository/book_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockSupabaseService extends Mock implements SupabaseService {}

class MockRatedBooksRemoteDataSource extends Mock
    implements RatedBooksRemoteDataSource {}

void main() {
  late MockSupabaseService supabase;
  late BookRepositoryImpl repository;

  setUpAll(() => registerFallbackValue(HttpMethod.post));

  const pageJson = {
    'items': [
      {
        'id': 'book-1',
        'title': 'Harry Potter e a Pedra Filosofal',
        'author': 'J. K. Rowling',
        'genre': 'Fantasia',
        'cover_url': null,
        'my_status': 'WANT_TO_READ',
      },
    ],
    'google_suggestions': [
      {
        'external_id': 'google-1',
        'title': 'Outro livro',
        'author': 'Autora',
        'cover_url': null,
        'source': 'google',
      },
    ],
    'page': 1,
    'page_size': 20,
    'has_more': false,
  };

  setUp(() {
    supabase = MockSupabaseService();
    repository = BookRepositoryImpl(supabaseService: supabase);
  });

  test('loads popular books without q', () async {
    when(
      () => supabase.invokeFunction<BookPageModel>(
        functionName: 'search-books',
        queryParameters: const {'page': '1', 'pageSize': '20'},
        method: HttpMethod.get,
        decoder: any(named: 'decoder'),
      ),
    ).thenAnswer((invocation) async {
      final decoder =
          invocation.namedArguments[#decoder]
              as BookPageModel Function(dynamic);
      return Success(SupabaseResponse(data: decoder(pageJson)));
    });

    final result = await repository.searchBooks(page: 1);

    expect(
      result,
      isA<Success<BookPage, BookFailure>>().having(
        (success) => success.data.items.single.myStatus,
        'status',
        BookReadingStatus.wantToRead,
      ),
    );
  });

  test('sends q when the query has at least 2 characters', () async {
    when(
      () => supabase.invokeFunction<BookPageModel>(
        functionName: 'search-books',
        queryParameters: const {'page': '2', 'pageSize': '20', 'q': 'harry'},
        method: HttpMethod.get,
        decoder: any(named: 'decoder'),
      ),
    ).thenAnswer((invocation) async {
      final decoder =
          invocation.namedArguments[#decoder]
              as BookPageModel Function(dynamic);
      return Success(SupabaseResponse(data: decoder(pageJson)));
    });

    await repository.searchBooks(query: ' harry ', page: 2);

    verify(
      () => supabase.invokeFunction<BookPageModel>(
        functionName: 'search-books',
        queryParameters: const {'page': '2', 'pageSize': '20', 'q': 'harry'},
        method: HttpMethod.get,
        decoder: any(named: 'decoder'),
      ),
    ).called(1);
  });

  test('drops a query shorter than 2 characters', () async {
    when(
      () => supabase.invokeFunction<BookPageModel>(
        functionName: 'search-books',
        queryParameters: const {'page': '1', 'pageSize': '20'},
        method: HttpMethod.get,
        decoder: any(named: 'decoder'),
      ),
    ).thenAnswer((invocation) async {
      final decoder =
          invocation.namedArguments[#decoder]
              as BookPageModel Function(dynamic);
      return Success(SupabaseResponse(data: decoder(pageJson)));
    });

    await repository.searchBooks(query: ' h ', page: 1);

    verify(
      () => supabase.invokeFunction<BookPageModel>(
        functionName: 'search-books',
        queryParameters: const {'page': '1', 'pageSize': '20'},
        method: HttpMethod.get,
        decoder: any(named: 'decoder'),
      ),
    ).called(1);
  });

  for (final (kind, expected) in const <(SupabaseFailureKind, BookFailure)>[
    (SupabaseFailureKind.network, BookNetworkFailure()),
    (SupabaseFailureKind.unauthorized, BookSessionExpiredFailure()),
    (SupabaseFailureKind.forbidden, BookSearchFailure()),
    (SupabaseFailureKind.server, BookSearchFailure()),
    (SupabaseFailureKind.unknown, BookSearchFailure()),
  ]) {
    test('maps a ${kind.name} search failure', () async {
      when(
        () => supabase.invokeFunction<BookPageModel>(
          functionName: 'search-books',
          queryParameters: any(named: 'queryParameters'),
          method: HttpMethod.get,
          decoder: any(named: 'decoder'),
        ),
      ).thenAnswer(
        (_) async =>
            Failure(FunctionSupabaseFailure(message: 'down', kind: kind)),
      );

      final result = await repository.searchBooks(page: 1);

      expect(result, Failure<BookPage, BookFailure>(expected));
    });
  }

  test('posts set-book-reading-status and reads the status back', () async {
    when(
      () => supabase.invokeFunction<BookReadingStatus?>(
        functionName: 'set-book-reading-status',
        body: {'book_id': 'book-1', 'status': 'READ'},
        decoder: any(named: 'decoder'),
      ),
    ).thenAnswer((invocation) async {
      final decoder =
          invocation.namedArguments[#decoder]
              as BookReadingStatus? Function(dynamic);
      return Success(
        SupabaseResponse(
          data: decoder({'book_id': 'book-1', 'status': 'READ'}),
        ),
      );
    });

    final result = await repository.setReadingStatus(
      bookId: 'book-1',
      status: BookReadingStatus.read,
    );

    expect(
      result,
      const Success<BookReadingStatus?, BookFailure>(BookReadingStatus.read),
    );
  });

  test('posts null to clear the status', () async {
    when(
      () => supabase.invokeFunction<BookReadingStatus?>(
        functionName: 'set-book-reading-status',
        body: {'book_id': 'book-1', 'status': null},
        decoder: any(named: 'decoder'),
      ),
    ).thenAnswer((invocation) async {
      final decoder =
          invocation.namedArguments[#decoder]
              as BookReadingStatus? Function(dynamic);
      return Success(
        SupabaseResponse(data: decoder({'book_id': 'book-1', 'status': null})),
      );
    });

    final result = await repository.setReadingStatus(
      bookId: 'book-1',
      status: null,
    );

    expect(result, const Success<BookReadingStatus?, BookFailure>(null));
  });

  test('maps a status failure', () async {
    when(
      () => supabase.invokeFunction<BookReadingStatus?>(
        functionName: 'set-book-reading-status',
        body: any(named: 'body'),
        decoder: any(named: 'decoder'),
      ),
    ).thenAnswer(
      (_) async => const Failure(
        FunctionSupabaseFailure(message: 'book_not_found', code: '404'),
      ),
    );

    final result = await repository.setReadingStatus(
      bookId: 'missing',
      status: BookReadingStatus.read,
    );

    expect((result as Failure).failure, isA<BookStatusFailure>());
  });

  test('returns a search failure when the response has no page data', () async {
    when(
      () => supabase.invokeFunction<BookPageModel>(
        functionName: 'search-books',
        queryParameters: any(named: 'queryParameters'),
        method: HttpMethod.get,
        decoder: any(named: 'decoder'),
      ),
    ).thenAnswer((_) async => const Success(SupabaseResponse()));

    expect(
      await repository.searchBooks(page: 1),
      const Failure<BookPage, BookFailure>(BookSearchFailure()),
    );
  });

  test('posts upsert-book-review with the review data', () async {
    when(
      () => supabase.invokeFunction<void>(
        functionName: 'upsert-book-review',
        body: {'book_id': 'book-1', 'rating': 5, 'commentary': 'Muito bom'},
      ),
    ).thenAnswer((_) async => const Success(SupabaseResponse<void>()));

    final result = await repository.upsertBookReview(
      bookId: 'book-1',
      rating: 5,
      commentary: 'Muito bom',
    );

    expect(result, const Success<void, BookFailure>(null));
    verify(
      () => supabase.invokeFunction<void>(
        functionName: 'upsert-book-review',
        body: {'book_id': 'book-1', 'rating': 5, 'commentary': 'Muito bom'},
      ),
    ).called(1);
  });

  test('maps upsert-book-review failures', () async {
    when(
      () => supabase.invokeFunction<void>(
        functionName: 'upsert-book-review',
        body: any(named: 'body'),
      ),
    ).thenAnswer(
      (_) async =>
          const Failure(FunctionSupabaseFailure(message: 'invalid review')),
    );

    final result = await repository.upsertBookReview(
      bookId: 'book-1',
      rating: 1,
      commentary: null,
    );

    expect(result, const Failure<void, BookFailure>(BookReviewFailure()));
  });

  group('getBookDetails', () {
    void stubDetails(
      Result<SupabaseResponse<BookDetailsModel>, SupabaseFailure> result,
    ) {
      when(
        () => supabase.invokeFunction<BookDetailsModel>(
          functionName: any(named: 'functionName'),
          method: any(named: 'method'),
          queryParameters: any(named: 'queryParameters'),
          decoder: any(named: 'decoder'),
        ),
      ).thenAnswer((_) async => result);
    }

    test('sends a GET with the book and the reviews page', () async {
      stubDetails(
        const Success(
          SupabaseResponse(
            data: BookDetailsModel(
              id: 'b1',
              title: 'Livro',
              author: 'Autora',
              genre: '',
              publisher: '',
              ratingsCount: 0,
              reviews: [],
              hasMoreReviews: false,
            ),
          ),
        ),
      );

      final result = await repository.getBookDetails(
        bookId: 'b1',
        reviewsPage: 2,
      );

      expect(result.unwrap().title, 'Livro');
      final call = verify(
        () => supabase.invokeFunction<BookDetailsModel>(
          functionName: 'get-book-details',
          method: HttpMethod.get,
          queryParameters: {
            'bookId': 'b1',
            'reviewsPage': '2',
            'reviewsPageSize': '${BookRepository.reviewsPageSize}',
          },
          decoder: captureAny(named: 'decoder'),
        ),
      )..called(1);

      final decoder =
          call.captured.single as BookDetailsModel Function(dynamic);
      expect(
        decoder({
          'id': 'b2',
          'title': 'Outro',
          'ratings_count': 0,
          'reviews': {'items': <dynamic>[], 'has_more': false},
        }).title,
        'Outro',
      );
    });

    test('maps 404 and an invalid id (400) to BookNotFoundFailure', () async {
      for (final kind in [
        SupabaseFailureKind.notFound,
        SupabaseFailureKind.validation,
      ]) {
        stubDetails(Failure(FunctionSupabaseFailure(message: 'x', kind: kind)));

        expect(
          await repository.getBookDetails(bookId: 'b1'),
          const Failure<BookDetailsEntity, BookFailure>(BookNotFoundFailure()),
          reason: '$kind',
        );
      }
    });

    test('maps no connection and an expired session', () async {
      stubDetails(
        const Failure(
          FunctionSupabaseFailure(
            message: 'x',
            kind: SupabaseFailureKind.network,
          ),
        ),
      );
      expect(
        await repository.getBookDetails(bookId: 'b1'),
        const Failure<BookDetailsEntity, BookFailure>(BookNetworkFailure()),
      );

      stubDetails(
        const Failure(
          FunctionSupabaseFailure(
            message: 'x',
            kind: SupabaseFailureKind.unauthorized,
          ),
        ),
      );
      expect(
        await repository.getBookDetails(bookId: 'b1'),
        const Failure<BookDetailsEntity, BookFailure>(
          BookSessionExpiredFailure(),
        ),
      );
    });

    test(
      'maps other failures and empty data to BookDetailsLoadFailure',
      () async {
        stubDetails(
          const Failure(FunctionSupabaseFailure(message: 'x', code: '500')),
        );
        expect(
          await repository.getBookDetails(bookId: 'b1'),
          const Failure<BookDetailsEntity, BookFailure>(
            BookDetailsLoadFailure(),
          ),
        );

        stubDetails(const Success(SupabaseResponse()));
        expect(
          await repository.getBookDetails(bookId: 'b1'),
          const Failure<BookDetailsEntity, BookFailure>(
            BookDetailsLoadFailure(),
          ),
        );
      },
    );
  });

  group('getRatedBooks', () {
    late MockRatedBooksRemoteDataSource mockDataSource;
    late BookRepositoryImpl repoWithMock;

    setUp(() {
      mockDataSource = MockRatedBooksRemoteDataSource();
      repoWithMock = BookRepositoryImpl(
        supabaseService: supabase,
        ratedBooksRemoteDataSource: mockDataSource,
      );
    });

    const tModel = RatedBookModel(
      id: 'r1',
      bookId: 'b1',
      title: 'Title',
      author: 'Author',
      rating: 5.0,
    );

    test('returns mapped RatedBook entities on success', () async {
      when(
        () => mockDataSource.getRatedBooks(page: 1, limit: 10),
      ).thenAnswer((_) async => [tModel]);

      final result = await repoWithMock.getRatedBooks(page: 1, limit: 10);

      expect(result, isA<Success<List<RatedBook>, BookFailure>>());
      final books = (result as Success<List<RatedBook>, BookFailure>).data;
      expect(books.length, 1);
      expect(books.first.title, 'Title');
    });

    test('maps SupabaseFailure to BookFailure', () async {
      when(() => mockDataSource.getRatedBooks(page: 1, limit: 10)).thenThrow(
        const FunctionSupabaseFailure(
          message: 'net',
          kind: SupabaseFailureKind.network,
        ),
      );

      final result = await repoWithMock.getRatedBooks(page: 1, limit: 10);

      expect(
        result,
        const Failure<List<RatedBook>, BookFailure>(BookNetworkFailure()),
      );

      when(() => mockDataSource.getRatedBooks(page: 1, limit: 10)).thenThrow(
        const FunctionSupabaseFailure(
          message: 'auth',
          kind: SupabaseFailureKind.unauthorized,
        ),
      );

      final resultAuth = await repoWithMock.getRatedBooks(page: 1, limit: 10);

      expect(
        resultAuth,
        const Failure<List<RatedBook>, BookFailure>(
          BookSessionExpiredFailure(),
        ),
      );
    });

    test('maps generic exceptions to RatedBooksLoadFailure', () async {
      when(
        () => mockDataSource.getRatedBooks(page: 1, limit: 10),
      ).thenThrow(Exception('boom'));

      final result = await repoWithMock.getRatedBooks(page: 1, limit: 10);

      expect(
        result,
        const Failure<List<RatedBook>, BookFailure>(RatedBooksLoadFailure()),
      );
    });
  });

  group('book recommendations', () {
    test('loads recommendation groups with the book id', () async {
      when(
        () => supabase.invokeFunction<List<BookRecommendationGroupModel>>(
          functionName: 'get-book-recommendation-groups',
          method: HttpMethod.get,
          queryParameters: const {'bookId': 'book-1'},
          decoder: any(named: 'decoder'),
        ),
      ).thenAnswer((invocation) async {
        final decoder =
            invocation.namedArguments[#decoder]
                as List<BookRecommendationGroupModel> Function(dynamic);
        return Success(
          SupabaseResponse(
            data: decoder({
              'items': [
                {
                  'group_id': 'group-1',
                  'name': 'Grupo 1',
                  'number': 1,
                  'photo_url': null,
                  'already_recommended': false,
                },
              ],
            }),
          ),
        );
      });

      expect(
        await repository.getBookRecommendationGroups(bookId: 'book-1'),
        const Success<List<BookRecommendationGroup>, BookFailure>([
          BookRecommendationGroup(
            id: 'group-1',
            number: 1,
            name: 'Grupo 1',
            alreadyRecommended: false,
          ),
        ]),
      );
    });

    test(
      'returns BookRecommendationGroupsFailure when payload data is null',
      () async {
        when(
          () => supabase.invokeFunction<List<BookRecommendationGroupModel>>(
            functionName: 'get-book-recommendation-groups',
            method: HttpMethod.get,
            queryParameters: const {'bookId': 'book-1'},
            decoder: any(named: 'decoder'),
          ),
        ).thenAnswer((_) async => const Success(SupabaseResponse()));

        expect(
          await repository.getBookRecommendationGroups(bookId: 'book-1'),
          const Failure<List<BookRecommendationGroup>, BookFailure>(
            BookRecommendationGroupsFailure(),
          ),
        );
      },
    );

    test('posts the book and group ids to recommend-book', () async {
      when(
        () => supabase.invokeFunction<BookRecommendationOutcome>(
          functionName: 'recommend-book',
          body: const {'book_id': 'book-1', 'group_id': 'group-1'},
          decoder: any(named: 'decoder'),
        ),
      ).thenAnswer((invocation) async {
        final decoder =
            invocation.namedArguments[#decoder]
                as BookRecommendationOutcome Function(dynamic);
        return Success(
          SupabaseResponse<BookRecommendationOutcome>(
            data: decoder({'id': 's1', 'replaced': false}),
          ),
        );
      });

      expect(
        await repository.recommendBook(bookId: 'book-1', groupId: 'group-1'),
        const Success<BookRecommendationOutcome, BookFailure>(
          BookRecommendationOutcome.created,
        ),
      );
    });

    test('returns replaced outcome when backend replaced active suggestion', () async {
      when(
        () => supabase.invokeFunction<BookRecommendationOutcome>(
          functionName: 'recommend-book',
          body: const {'book_id': 'book-1', 'group_id': 'group-1'},
          decoder: any(named: 'decoder'),
        ),
      ).thenAnswer((invocation) async {
        final decoder =
            invocation.namedArguments[#decoder]
                as BookRecommendationOutcome Function(dynamic);
        return Success(
          SupabaseResponse<BookRecommendationOutcome>(
            data: decoder({'id': 's1', 'replaced': true}),
          ),
        );
      });

      expect(
        await repository.recommendBook(bookId: 'book-1', groupId: 'group-1'),
        const Success<BookRecommendationOutcome, BookFailure>(
          BookRecommendationOutcome.replaced,
        ),
      );
    });

    test('maps a recommendation conflict to already recommended', () async {
      when(
        () => supabase.invokeFunction<BookRecommendationOutcome>(
          functionName: 'recommend-book',
          body: any(named: 'body'),
          decoder: any(named: 'decoder'),
        ),
      ).thenAnswer(
        (_) async => const Failure(
          FunctionSupabaseFailure(
            message: 'already_recommended',
            code: '409',
            kind: SupabaseFailureKind.conflict,
          ),
        ),
      );

      expect(
        await repository.recommendBook(bookId: 'book-1', groupId: 'group-1'),
        const Failure<BookRecommendationOutcome, BookFailure>(
          BookAlreadyRecommendedFailure(),
        ),
      );
    });

    test('maps host_not_eligible 403 to host blocked failure', () async {
      when(
        () => supabase.invokeFunction<BookRecommendationOutcome>(
          functionName: 'recommend-book',
          body: any(named: 'body'),
          decoder: any(named: 'decoder'),
        ),
      ).thenAnswer(
        (_) async => const Failure(
          FunctionSupabaseFailure(
            message: 'host_not_eligible',
            code: '403',
            details: {'error': 'host_not_eligible'},
            kind: SupabaseFailureKind.forbidden,
          ),
        ),
      );

      expect(
        await repository.recommendBook(bookId: 'book-1', groupId: 'group-1'),
        const Failure<BookRecommendationOutcome, BookFailure>(
          BookRecommendationHostBlockedFailure(),
        ),
      );
    });

    test('maps other 403 recommendation errors to generic failure', () async {
      when(
        () => supabase.invokeFunction<BookRecommendationOutcome>(
          functionName: 'recommend-book',
          body: any(named: 'body'),
          decoder: any(named: 'decoder'),
        ),
      ).thenAnswer(
        (_) async => const Failure(
          FunctionSupabaseFailure(
            message: 'not_group_member',
            code: '403',
            details: {'error': 'not_group_member'},
            kind: SupabaseFailureKind.forbidden,
          ),
        ),
      );

      expect(
        await repository.recommendBook(bookId: 'book-1', groupId: 'group-1'),
        const Failure<BookRecommendationOutcome, BookFailure>(
          BookRecommendationFailure(),
        ),
      );
    });

    test('maps recommendation group failures', () async {
      for (final (kind, expected) in const [
        (SupabaseFailureKind.network, BookNetworkFailure()),
        (SupabaseFailureKind.unauthorized, BookSessionExpiredFailure()),
        (SupabaseFailureKind.server, BookRecommendationGroupsFailure()),
      ]) {
        when(
          () => supabase.invokeFunction<List<BookRecommendationGroupModel>>(
            functionName: 'get-book-recommendation-groups',
            method: HttpMethod.get,
            queryParameters: const {'bookId': 'book-1'},
            decoder: any(named: 'decoder'),
          ),
        ).thenAnswer(
          (_) async =>
              Failure(FunctionSupabaseFailure(message: 'failure', kind: kind)),
        );

        expect(
          await repository.getBookRecommendationGroups(bookId: 'book-1'),
          Failure<List<BookRecommendationGroup>, BookFailure>(expected),
          reason: '$kind',
        );
      }
    });

    test('maps non-conflict recommendation failures', () async {
      when(
        () => supabase.invokeFunction<BookRecommendationOutcome>(
          functionName: 'recommend-book',
          body: any(named: 'body'),
          decoder: any(named: 'decoder'),
        ),
      ).thenAnswer(
        (_) async => const Failure(
          FunctionSupabaseFailure(
            message: 'offline',
            kind: SupabaseFailureKind.network,
          ),
        ),
      );

      expect(
        await repository.recommendBook(bookId: 'book-1', groupId: 'group-1'),
        const Failure<BookRecommendationOutcome, BookFailure>(
          BookNetworkFailure(),
        ),
      );
    });
  });
}
