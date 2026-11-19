import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Guarda o último token FCM registrado no backend.
///
/// Persistir (em vez de só manter em memória) permite desregistrar o aparelho
/// no logout mesmo depois de o app ser reaberto, quando o FCM ainda não
/// devolveu o token atual (no iOS, o do APNs pode demorar).
abstract class RegisteredTokenStore {
  Future<String?> read();
  Future<void> save(String token);
  Future<void> clear();
}

class SharedPreferencesRegisteredTokenStore implements RegisteredTokenStore {
  SharedPreferencesRegisteredTokenStore({
    Future<SharedPreferences> Function()? loadPreferences,
  }) : _loadPreferences = loadPreferences ?? SharedPreferences.getInstance;

  static const _key = 'notifications.registered_fcm_token';

  final Future<SharedPreferences> Function() _loadPreferences;

  @override
  Future<String?> read() async {
    try {
      final prefs = await _loadPreferences();
      return prefs.getString(_key);
    } catch (e) {
      // Sem armazenamento, o logout segue só com o token que o FCM devolver.
      if (kDebugMode) debugPrint('[RegisteredTokenStore] read failed: $e');
      return null;
    }
  }

  @override
  Future<void> save(String token) async {
    try {
      final prefs = await _loadPreferences();
      await prefs.setString(_key, token);
    } catch (e) {
      if (kDebugMode) debugPrint('[RegisteredTokenStore] save failed: $e');
    }
  }

  @override
  Future<void> clear() async {
    try {
      final prefs = await _loadPreferences();
      await prefs.remove(_key);
    } catch (e) {
      if (kDebugMode) debugPrint('[RegisteredTokenStore] clear failed: $e');
    }
  }
}
