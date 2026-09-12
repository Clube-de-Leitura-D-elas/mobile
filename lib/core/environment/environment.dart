import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  Environment._();

  static final Environment instance = Environment._();

  Future<void> load({String fileName = '.env'}) async {
    await dotenv.load(fileName: fileName);
  }

  String get baseUrl => dotenv.env['BASE_URL'] ?? 'http://localhost:8080';

  String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';

  String get supabaseAnonKey => dotenv.env['SUPABASE_PUBLISHABLE_KEY'] ?? '';

  bool get hasSupabaseConfig =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  String get iosClientId => dotenv.env['IOS_CLIENT_ID'] ?? '';
}
