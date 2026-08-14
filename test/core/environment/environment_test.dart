import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/environment/environment.dart';

void main() {
  group('Environment', () {
    test('returns correct baseUrl when dotenv is populated', () {
      dotenv.testLoad(fileInput: 'BASE_URL=http://api.example.com');

      expect(Environment.baseUrl, equals('http://api.example.com'));
    });

    test('returns default fallback baseUrl when BASE_URL key is missing', () {
      dotenv.testLoad(fileInput: '');

      expect(Environment.baseUrl, equals('http://localhost:8080'));
    });
  });
}
