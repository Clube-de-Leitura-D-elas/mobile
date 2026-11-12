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
  const TestSupabaseFailure(String message) : super(message: message);
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
      enableMockFallback: false,
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
          functionName: 'get-rated-books',
          method: HttpMethod.get,
          queryParameters: {'page': '1', 'limit': '10'},
          decoder: any(named: 'decoder'),
        ),
      ).thenAnswer(
        (_) async => const Success(
          SupabaseResponse(
            data: [tBookModel],
            statusCode: 200,
          ),
        ),
      );

      final result = await dataSource.getRatedBooks(page: 1, limit: 10);

      expect(result, [tBookModel]);
      verify(
        () => mockSupabaseService.invokeFunction<List<RatedBookModel>>(
          functionName: 'get-rated-books',
          method: HttpMethod.get,
          queryParameters: {'page': '1', 'limit': '10'},
          decoder: any(named: 'decoder'),
        ),
      ).called(1);
    });

    test(
      'throws exception when invokeFunction fails and mock fallback is disabled',
      () async {
        when(
          () => mockSupabaseService.invokeFunction<List<RatedBookModel>>(
            functionName: any(named: 'functionName'),
            method: any(named: 'method'),
            queryParameters: any(named: 'queryParameters'),
            decoder: any(named: 'decoder'),
          ),
        ).thenAnswer(
          (_) async => const Failure(TestSupabaseFailure('Erro de servidor')),
        );

        expect(
          () => dataSource.getRatedBooks(page: 1, limit: 10),
          throwsA(isA<Exception>()),
        );
      },
    );

    test(
      'returns mock data on invokeFunction failure when mock fallback is enabled',
      () async {
        final mockDataSource = RatedBooksRemoteDataSourceImpl(
          supabaseService: mockSupabaseService,
          enableMockFallback: true,
        );

        when(
          () => mockSupabaseService.invokeFunction<List<RatedBookModel>>(
            functionName: any(named: 'functionName'),
            method: any(named: 'method'),
            queryParameters: any(named: 'queryParameters'),
            decoder: any(named: 'decoder'),
          ),
        ).thenAnswer(
          (_) async => const Failure(TestSupabaseFailure('Function not found')),
        );

        final result = await mockDataSource.getRatedBooks(page: 1, limit: 10);

        expect(result, isNotEmpty);
        expect(result.first.title, 'Harry Potter e a Pedra Filosofal');
      },
    );
  });
}
