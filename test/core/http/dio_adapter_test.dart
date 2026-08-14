import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/http/dio/dio_adapter.dart';
import 'package:mobile/core/http/http_failures.dart';
import 'package:mobile/core/http/http_response.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  group('DioAdapter', () {
    late MockDio mockDio;
    late DioAdapter dioAdapter;

    setUp(() {
      mockDio = MockDio();
      dioAdapter = DioAdapter(dio: mockDio);
    });

    test('get returns Success when response status is 200', () async {
      final response = Response(
        requestOptions: RequestOptions(path: '/test'),
        statusCode: 200,
        data: {'data': 'ok'},
      );

      when(
        () => mockDio.get('/test', queryParameters: any(named: 'queryParameters')),
      ).thenAnswer((_) async => response);

      final result = await dioAdapter.get('/test', queryParameters: {'page': 1});

      expect(result, isA<Success<HttpResponse, HttpFailure>>());
      final success = result as Success<HttpResponse, HttpFailure>;
      expect(success.data.statusCode, equals(200));
      expect(success.data.data, equals({'data': 'ok'}));
    });

    test('post returns Success when request succeeds', () async {
      final response = Response(
        requestOptions: RequestOptions(path: '/test'),
        statusCode: 201,
        data: {'id': 1},
      );

      when(
        () => mockDio.post('/test', data: any(named: 'data')),
      ).thenAnswer((_) async => response);

      final result = await dioAdapter.post('/test', {'name': 'test'});

      expect(result, isA<Success<HttpResponse, HttpFailure>>());
      final success = result as Success<HttpResponse, HttpFailure>;
      expect(success.data.statusCode, equals(201));
    });

    test('put returns Success when request succeeds', () async {
      final response = Response(
        requestOptions: RequestOptions(path: '/test'),
        statusCode: 200,
        data: {'updated': true},
      );

      when(
        () => mockDio.put('/test', data: any(named: 'data')),
      ).thenAnswer((_) async => response);

      final result = await dioAdapter.put('/test', {'name': 'updated'});

      expect(result, isA<Success<HttpResponse, HttpFailure>>());
      final success = result as Success<HttpResponse, HttpFailure>;
      expect(success.data.statusCode, equals(200));
    });

    test('delete returns Success when request succeeds', () async {
      final response = Response(
        requestOptions: RequestOptions(path: '/test'),
        statusCode: 204,
        data: null,
      );

      when(
        () => mockDio.delete('/test', data: any(named: 'data')),
      ).thenAnswer((_) async => response);

      final result = await dioAdapter.delete('/test');

      expect(result, isA<Success<HttpResponse, HttpFailure>>());
      final success = result as Success<HttpResponse, HttpFailure>;
      expect(success.data.statusCode, equals(204));
    });

    test('returns Failure when response status is >= 400', () async {
      final response = Response(
        requestOptions: RequestOptions(path: '/test'),
        statusCode: 500,
        data: 'Internal server error',
      );

      when(
        () => mockDio.get('/test', queryParameters: any(named: 'queryParameters')),
      ).thenAnswer((_) async => response);

      final result = await dioAdapter.get('/test');

      expect(result, isA<Failure<HttpResponse, HttpFailure>>());
      final failure = (result as Failure<HttpResponse, HttpFailure>).failure;
      expect(failure, isA<InternalServerErrorFailure>());
      expect(failure.message, equals('Internal server error'));
    });

    test('maps 404 badResponse DioException to NotFoundFailure', () async {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 404,
          data: {'message': 'Resource not found'},
        ),
      );

      when(
        () => mockDio.get('/test', queryParameters: any(named: 'queryParameters')),
      ).thenThrow(dioException);

      final result = await dioAdapter.get('/test');

      expect(result, isA<Failure<HttpResponse, HttpFailure>>());
      final failure = (result as Failure<HttpResponse, HttpFailure>).failure;
      expect(failure, isA<NotFoundFailure>());
      expect(failure.message, equals('Resource not found'));
    });

    test('maps generic non-Dio exception to UnknownFailure', () async {
      when(
        () => mockDio.get('/test', queryParameters: any(named: 'queryParameters')),
      ).thenThrow(Exception('Unexpected error'));

      final result = await dioAdapter.get('/test');

      expect(result, isA<Failure<HttpResponse, HttpFailure>>());
      final failure = (result as Failure<HttpResponse, HttpFailure>).failure;
      expect(failure, isA<UnknownFailure>());
      expect(failure.message, contains('Unexpected error'));
    });
  });
}
