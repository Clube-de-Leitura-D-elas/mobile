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

    test('returns Success when response status is 200', () async {
      final response = Response(
        requestOptions: RequestOptions(path: '/test'),
        statusCode: 200,
        data: {'data': 'ok'},
      );

      when(
        () => mockDio.get('/test', queryParameters: any(named: 'queryParameters')),
      ).thenAnswer((_) async => response);

      final result = await dioAdapter.get('/test');

      expect(result, isA<Success<HttpResponse, HttpFailure>>());
      final success = result as Success<HttpResponse, HttpFailure>;
      expect(success.data.statusCode, equals(200));
      expect(success.data.data, equals({'data': 'ok'}));
    });

    test('maps 404 badResponse to NotFoundFailure with extracted message', () async {
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

    test('maps 401 badResponse to UnauthorizedFailure', () async {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 401,
          data: {'error': 'Invalid token'},
        ),
      );

      when(
        () => mockDio.post('/test', data: any(named: 'data')),
      ).thenThrow(dioException);

      final result = await dioAdapter.post('/test', {});

      expect(result, isA<Failure<HttpResponse, HttpFailure>>());
      final failure = (result as Failure<HttpResponse, HttpFailure>).failure;
      expect(failure, isA<UnauthorizedFailure>());
      expect(failure.message, equals('Invalid token'));
    });

    test('maps timeout DioException to RequestTimeoutFailure', () async {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionTimeout,
        message: 'Connection timed out',
      );

      when(
        () => mockDio.get('/test', queryParameters: any(named: 'queryParameters')),
      ).thenThrow(dioException);

      final result = await dioAdapter.get('/test');

      expect(result, isA<Failure<HttpResponse, HttpFailure>>());
      final failure = (result as Failure<HttpResponse, HttpFailure>).failure;
      expect(failure, isA<RequestTimeoutFailure>());
      expect(failure.message, equals('Connection timed out'));
    });
  });
}
