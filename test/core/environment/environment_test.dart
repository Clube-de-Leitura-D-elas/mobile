import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/environment/environment.dart';

void main() {
  final environment = Environment.instance;

  group('Environment', () {
    test('returns correct baseUrl when dotenv is populated', () {
      dotenv.testLoad(
        fileInput:
            'BASE_URL=http://api.example.com\nSUPABASE_URL=https://example.supabase.co\nSUPABASE_PUBLISHABLE_KEY=anon-key',
      );

      expect(environment.baseUrl, equals('http://api.example.com'));
    });

    test('returns default fallback baseUrl when BASE_URL key is missing', () {
      dotenv.testLoad(fileInput: '');

      expect(environment.baseUrl, equals('http://localhost:8080'));
    });

    test('returns Supabase URL and anon key when dotenv is populated', () {
      dotenv.testLoad(
        fileInput:
            'SUPABASE_URL=https://example.supabase.co\nSUPABASE_PUBLISHABLE_KEY=anon-key',
      );

      expect(environment.supabaseUrl, equals('https://example.supabase.co'));
      expect(environment.supabaseAnonKey, equals('anon-key'));
    });

    test('returns empty Supabase values when keys are missing', () {
      dotenv.testLoad(fileInput: '');

      expect(environment.supabaseUrl, isEmpty);
      expect(environment.supabaseAnonKey, isEmpty);
    });
  });
}
