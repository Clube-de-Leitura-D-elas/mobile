import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class Environment {
  static Future<void> load({String fileName = '.env'}) async {
    await dotenv.load(fileName: fileName);
  }

  static String get baseUrl =>
      dotenv.env['BASE_URL'] ?? 'http://localhost:8080';
}
