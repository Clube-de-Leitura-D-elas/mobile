import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/supabase/supabase_failure.dart';
import 'package:mobile/core/supabase/supabase_response.dart';
import 'package:mobile/core/supabase/supabase_service.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/books/data/datasources/rated_books_remote_data_source.dart';
import 'package:mobile/features/books/data/models/rated_book_model.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseService extends Mock implements SupabaseService {}

class TestSupabaseFailure extends SupabaseFailure {
  const TestSupabaseFailure(
    String message, {
    super.kind = SupabaseFailureKind.unknown,
  }) : super(message: message);
}

void main() {
  late RatedBooksRemoteDataSourceImpl dataSource;
  late MockSupabaseService mockSupabaseService;

  setUpAll(() {
    registerFallbackValue(HttpMethod.get);
  });

  setUp(() {
    mockSupabaseService = MockSupabaseService();
    dataSource = RatedBooksRemoteDataSourceImpl(
      supabaseService: mockSupabaseService,
    );
  });

  group('RatedBooksRemoteDataSource', () {
    const tBookModel = RatedBookModel(
      id: 'rated-1',
      bookId: 'book-1',
      title: 'Harry Potter e a Pedra Filosofal',
      author: 'J. K. Rowling',
      rating: 4.5,
    );

    test('returns rated books list on successful invokeFunction', () async {
      when(
        () => mockSupabaseService.invokeFunction<List<RatedBookModel>>(
          functionName: 'get-my-reviewed-books',
          method: HttpMethod.get,
          queryParameters: {'page': '1', 'pageSize': '10'},
          decoder: any(named: 'decoder'),
        ),
      ).thenAnswer(
        (_) async => const Success(
          SupabaseResponse(data: [tBookModel], statusCode: 200),
        ),
      );

      final result = await dataSource.getRatedBooks(page: 1, limit: 10);

      expect(result, [tBookModel]);
      verify(
        () => mockSupabaseService.invokeFunction<List<RatedBookModel>>(
          functionName: 'get-my-reviewed-books',
          method: HttpMethod.get,
          queryParameters: {'page': '1', 'pageSize': '10'},
          decoder: any(named: 'decoder'),
        ),
      ).called(1);
    });

    test(
      'throws SupabaseFailure preserving kind when invokeFunction fails',
      () async {
        const failure = TestSupabaseFailure(
          'Erro de conexão',
          kind: SupabaseFailureKind.network,
        );

        when(
          () => mockSupabaseService.invokeFunction<List<RatedBookModel>>(
            functionName: any(named: 'functionName'),
            method: any(named: 'method'),
            queryParameters: any(named: 'queryParameters'),
            decoder: any(named: 'decoder'),
          ),
        ).thenAnswer((_) async => const Failure(failure));

        expect(
          () => dataSource.getRatedBooks(page: 1, limit: 10),
          throwsA(
            isA<TestSupabaseFailure>().having(
              (f) => f.kind,
              'kind',
              SupabaseFailureKind.network,
            ),
          ),
        );
      },
    );

    test(
      'decodes response using items envelope when decoder is invoked',
      () async {
        final rawPayload = {
          'items': [
            {
              'id': 'rated-1',
              'book_id': 'book-1',
              'title': 'Harry Potter e a Pedra Filosofal',
              'author': 'J. K. Rowling',
              'rating': 4.5,
            },
          ],
        };

        when(
          () => mockSupabaseService.invokeFunction<List<RatedBookModel>>(
            functionName: any(named: 'functionName'),
            method: any(named: 'method'),
            queryParameters: any(named: 'queryParameters'),
            decoder: any(named: 'decoder'),
          ),
        ).thenAnswer((invocation) async {
          final decoder =
              invocation.namedArguments[#decoder]
                  as List<RatedBookModel> Function(dynamic);
          final decoded = decoder(rawPayload);
          return Success(SupabaseResponse(data: decoded, statusCode: 200));
        });

        final result = await dataSource.getRatedBooks(page: 1, limit: 10);

        expect(result.length, 1);
        expect(result.first.id, 'rated-1');
        expect(result.first.bookId, 'book-1');
        expect(result.first.title, 'Harry Potter e a Pedra Filosofal');
        expect(result.first.rating, 4.5);
      },
    );

    test(
      'throws FormatException when decoder receives unexpected payload shape',
      () async {
        when(
          () => mockSupabaseService.invokeFunction<List<RatedBookModel>>(
            functionName: any(named: 'functionName'),
            method: any(named: 'method'),
            queryParameters: any(named: 'queryParameters'),
            decoder: any(named: 'decoder'),
          ),
        ).thenAnswer((invocation) async {
          final decoder =
              invocation.namedArguments[#decoder]
                  as List<RatedBookModel> Function(dynamic);
          final decoded = decoder({'unexpected': []});
          return Success(SupabaseResponse(data: decoded, statusCode: 200));
        });

        expect(
          () => dataSource.getRatedBooks(page: 1, limit: 10),
          throwsA(isA<FormatException>()),
        );
      },
    );
  });
}
