import 'package:jwt_decoder/jwt_decoder.dart';

class JwtDecoder {
  static bool isExpired(String token) {
    return JwtDecoder.isExpired(token); // Verifica si el token ha caducado
  }
}
