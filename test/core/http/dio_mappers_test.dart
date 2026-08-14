import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/http/dio/dio_mappers.dart';
import 'package:mobile/core/http/http_failures.dart';

void main() {
  group('DioMappers', () {
    group('mapDioExceptionToFailure', () {
      test('maps timeout exceptions to RequestTimeoutFailure', () {
        final requestOptions = RequestOptions(path: '/test');

        final connectionTimeout = DioException(
          requestOptions: requestOptions,
          type: DioExceptionType.connectionTimeout,
          message: 'Connection timeout',
        );

        final sendTimeout = DioException(
          requestOptions: requestOptions,
          type: DioExceptionType.sendTimeout,
          message: 'Send timeout',
        );

        final receiveTimeout = DioException(
          requestOptions: requestOptions,
          type: DioExceptionType.receiveTimeout,
          message: 'Receive timeout',
        );

        expect(
          mapDioExceptionToFailure(connectionTimeout),
          isA<RequestTimeoutFailure>(),
        );
        expect(
          mapDioExceptionToFailure(sendTimeout),
          isA<RequestTimeoutFailure>(),
        );
        expect(
          mapDioExceptionToFailure(receiveTimeout),
          isA<RequestTimeoutFailure>(),
        );
      });

      test('maps badResponse with valid response to matching HttpFailure', () {
        final requestOptions = RequestOptions(path: '/test');
        final badResponse = DioException(
          requestOptions: requestOptions,
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: requestOptions,
            statusCode: 403,
            data: {'message': 'Access forbidden'},
          ),
        );

        final failure = mapDioExceptionToFailure(badResponse);
        expect(failure, isA<ForbiddenFailure>());
        expect(failure.message, equals('Access forbidden'));
      });

      test('maps cancel exception to UnknownFailure with cancelled message', () {
        final exception = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.cancel,
        );

        final failure = mapDioExceptionToFailure(exception);
        expect(failure, isA<UnknownFailure>());
        expect(failure.message, equals('Request cancelled'));
      });

      test('maps badCertificate exception to UnknownFailure', () {
        final exception = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.badCertificate,
          message: 'Invalid certificate',
        );

        final failure = mapDioExceptionToFailure(exception);
        expect(failure, isA<UnknownFailure>());
        expect(failure.message, equals('Invalid certificate'));
      });

      test('maps connectionError exception to UnknownFailure', () {
        final exception = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.connectionError,
          message: 'Network unreachable',
        );

        final failure = mapDioExceptionToFailure(exception);
        expect(failure, isA<UnknownFailure>());
        expect(failure.message, equals('Network unreachable'));
      });

      test('maps unknown exception to UnknownFailure', () {
        final exception = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.unknown,
          message: 'Unknown error occurred',
        );

        final failure = mapDioExceptionToFailure(exception);
        expect(failure, isA<UnknownFailure>());
        expect(failure.message, equals('Unknown error occurred'));
      });
    });

    group('extractErrorMessage', () {
      test('returns string data directly if non-empty', () {
        expect(extractErrorMessage('Direct error message'), equals('Direct error message'));
      });

      test('extracts message from map containing message key', () {
        expect(extractErrorMessage({'message': 'Map message'}), equals('Map message'));
      });

      test('extracts error from map containing error key', () {
        expect(extractErrorMessage({'error': 'Map error'}), equals('Map error'));
      });

      test('extracts detail from map containing detail key', () {
        expect(extractErrorMessage({'detail': 'Map detail'}), equals('Map detail'));
      });

      test('returns fallback if data is null or empty map', () {
        expect(extractErrorMessage(null, 'Custom fallback'), equals('Custom fallback'));
        expect(extractErrorMessage({}, 'Custom fallback'), equals('Custom fallback'));
        expect(extractErrorMessage(123, 'Custom fallback'), equals('Custom fallback'));
      });

      test('returns "Unknown error" default when fallback is omitted', () {
        expect(extractErrorMessage(null), equals('Unknown error'));
      });
    });
  });
}
