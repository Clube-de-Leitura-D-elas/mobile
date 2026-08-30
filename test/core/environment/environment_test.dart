import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/environment/environment.dart';

void main() {
  group('Environment', () {
    test('returns correct baseUrl when dotenv is populated', () {
      dotenv.testLoad(
        fileInput: 'BASE_URL=http://api.example.com\nSUPABASE_URL=https://example.supabase.co\nSUPABASE_ANON_KEY=anon-key',
      );

      expect(Environment.baseUrl, equals('http://api.example.com'));
    });

    test('returns default fallback baseUrl when BASE_URL key is missing', () {
      dotenv.testLoad(fileInput: '');

      expect(Environment.baseUrl, equals('http://localhost:8080'));
    });

    test('returns Supabase URL and anon key when dotenv is populated', () {
      dotenv.testLoad(
        fileInput: 'SUPABASE_URL=https://example.supabase.co\nSUPABASE_ANON_KEY=anon-key',
      );

      expect(Environment.supabaseUrl, equals('https://example.supabase.co'));
      expect(Environment.supabaseAnonKey, equals('anon-key'));
    });

    test('returns empty Supabase values when keys are missing', () {
      dotenv.testLoad(fileInput: '');

      expect(Environment.supabaseUrl, isEmpty);
      expect(Environment.supabaseAnonKey, isEmpty);
    });
  });
}
