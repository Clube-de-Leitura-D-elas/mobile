import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/environment/environment.dart';

void main() {
  setUp(() {
    dotenv.testLoad(fileInput: 'BASE_URL=http://localhost:8080');
  });

  test('Environment instance properties return defaults when dotenv is loaded', () {
    final env = Environment.instance;

    expect(env.baseUrl, equals('http://localhost:8080'));
    expect(env.supabaseUrl, equals(''));
    expect(env.supabaseAnonKey, equals(''));
    expect(env.hasSupabaseConfig, isFalse);
    expect(env.iosClientId, equals(''));
  });
}
