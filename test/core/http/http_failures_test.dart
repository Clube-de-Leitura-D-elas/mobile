import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/http/http_failures.dart';

void main() {
  group('HttpFailures', () {
    test('HttpFailure props contains message', () {
      const failure1 = HttpFailure('Error message');
      const failure2 = HttpFailure('Error message');
      const failure3 = HttpFailure('Different message');

      expect(failure1.props, equals(['Error message']));
      expect(failure1, equals(failure2));
      expect(failure1, isNot(equals(failure3)));
    });

    group('httpFailureFromStatusCode', () {
      test('maps 400 to BadRequestFailure', () {
        final failure = httpFailureFromStatusCode(400, 'Bad Request');
        expect(failure, isA<BadRequestFailure>());
        expect(failure.message, equals('Bad Request'));
      });

      test('maps 401 to UnauthorizedFailure', () {
        final failure = httpFailureFromStatusCode(401, 'Unauthorized');
        expect(failure, isA<UnauthorizedFailure>());
        expect(failure.message, equals('Unauthorized'));
      });

      test('maps 403 to ForbiddenFailure', () {
        final failure = httpFailureFromStatusCode(403, 'Forbidden');
        expect(failure, isA<ForbiddenFailure>());
        expect(failure.message, equals('Forbidden'));
      });

      test('maps 404 to NotFoundFailure', () {
        final failure = httpFailureFromStatusCode(404, 'Not Found');
        expect(failure, isA<NotFoundFailure>());
        expect(failure.message, equals('Not Found'));
      });

      test('maps 405 to MethodNotAllowedFailure', () {
        final failure = httpFailureFromStatusCode(405, 'Method Not Allowed');
        expect(failure, isA<MethodNotAllowedFailure>());
        expect(failure.message, equals('Method Not Allowed'));
      });

      test('maps 406 to NotAcceptableFailure', () {
        final failure = httpFailureFromStatusCode(406, 'Not Acceptable');
        expect(failure, isA<NotAcceptableFailure>());
        expect(failure.message, equals('Not Acceptable'));
      });

      test('maps 408 to RequestTimeoutFailure', () {
        final failure = httpFailureFromStatusCode(408, 'Request Timeout');
        expect(failure, isA<RequestTimeoutFailure>());
        expect(failure.message, equals('Request Timeout'));
      });

      test('maps 409 to ConflictFailure', () {
        final failure = httpFailureFromStatusCode(409, 'Conflict');
        expect(failure, isA<ConflictFailure>());
        expect(failure.message, equals('Conflict'));
      });

      test('maps 429 to TooManyRequestsFailure', () {
        final failure = httpFailureFromStatusCode(429, 'Too Many Requests');
        expect(failure, isA<TooManyRequestsFailure>());
        expect(failure.message, equals('Too Many Requests'));
      });

      test('maps 500 to InternalServerErrorFailure', () {
        final failure = httpFailureFromStatusCode(500, 'Internal Server Error');
        expect(failure, isA<InternalServerErrorFailure>());
        expect(failure.message, equals('Internal Server Error'));
      });

      test('maps 502 to BadGatewayFailure', () {
        final failure = httpFailureFromStatusCode(502, 'Bad Gateway');
        expect(failure, isA<BadGatewayFailure>());
        expect(failure.message, equals('Bad Gateway'));
      });

      test('maps 503 to ServiceUnavailableFailure', () {
        final failure = httpFailureFromStatusCode(503, 'Service Unavailable');
        expect(failure, isA<ServiceUnavailableFailure>());
        expect(failure.message, equals('Service Unavailable'));
      });

      test('maps 504 to GatewayTimeoutFailure', () {
        final failure = httpFailureFromStatusCode(504, 'Gateway Timeout');
        expect(failure, isA<GatewayTimeoutFailure>());
        expect(failure.message, equals('Gateway Timeout'));
      });

      test('maps unhandled status code to UnknownFailure', () {
        final failure = httpFailureFromStatusCode(505, 'HTTP Version Not Supported');
        expect(failure, isA<UnknownFailure>());
        expect(failure.message, equals('HTTP Version Not Supported'));
      });
    });
  });
}
