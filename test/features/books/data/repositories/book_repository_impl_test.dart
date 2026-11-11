import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mobile/core/supabase/supabase_failure.dart';
import 'package:mobile/core/supabase/supabase_response.dart';
import 'package:mobile/core/supabase/supabase_service.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/books/data/models/book_page_model.dart';
import 'package:mobile/features/books/data/repositories/book_repository_impl.dart';
import 'package:mobile/features/books/domain/entities/book_failure.dart';
import 'package:mobile/features/books/domain/entities/book_page.dart';
import 'package:mobile/features/books/domain/entities/book_reading_status.dart';
import 'package:mocktail/mocktail.dart';

class MockSupabaseService extends Mock implements SupabaseService {}

void main() {
  late MockSupabaseService supabase;
  late BookRepositoryImpl repository;

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
}
