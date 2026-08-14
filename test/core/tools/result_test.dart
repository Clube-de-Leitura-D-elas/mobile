import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/tools/result.dart';

void main() {
  group('Result', () {
    group('Success', () {
      test('props contains data', () {
        const success1 = Success<String, String>('data');
        const success2 = Success<String, String>('data');
        const success3 = Success<String, String>('other');

        expect(success1.props, equals(['data']));
        expect(success1, equals(success2));
        expect(success1, isNot(equals(success3)));
      });

      test('unwrap returns data', () {
        const result = Success<int, String>(42);
        expect(result.unwrap(), equals(42));
      });

      test('unwrapOr returns data', () {
        const result = Success<int, String>(42);
        expect(result.unwrapOr(0), equals(42));
      });

      test('match calls onSuccess callback', () {
        const result = Success<int, String>(42);
        final matched = result.match(
          (data) => 'Success: $data',
          (failure) => 'Failure: $failure',
        );

        expect(matched, equals('Success: 42'));
      });
    });

    group('Failure', () {
      test('props contains failure object', () {
        const failure1 = Failure<String, String>('error');
        const failure2 = Failure<String, String>('error');
        const failure3 = Failure<String, String>('other error');

        expect(failure1.props, equals(['error']));
        expect(failure1, equals(failure2));
        expect(failure1, isNot(equals(failure3)));
      });

      test('unwrap throws exception', () {
        const result = Failure<int, String>('error');
        expect(() => result.unwrap(), throwsA(isA<Exception>()));
      });

      test('unwrapOr returns placeholder', () {
        const result = Failure<int, String>('error');
        expect(result.unwrapOr(99), equals(99));
      });

      test('match calls onFailure callback', () {
        const result = Failure<int, String>('something went wrong');
        final matched = result.match(
          (data) => 'Success: $data',
          (failure) => 'Failure: $failure',
        );

        expect(matched, equals('Failure: something went wrong'));
      });
    });
  });
}
