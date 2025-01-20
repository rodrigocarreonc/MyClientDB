import 'package:shared_preferences/shared_preferences.dart';

class JwtStorage {
  static const String _keyToken = 'jwt_token';

  // Guarda el token en almacenamiento local
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
  }

  // Obtiene el token del almacenamiento local
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  // Limpia el token del almacenamiento local
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
  }
}
