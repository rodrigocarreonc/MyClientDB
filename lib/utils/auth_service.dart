import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'jwt_storage.dart';

class AuthService {
  static const String baseUrl = 'https://api.myclientdb.rodrigocarreon.com/api';

  // Variable global para almacenar el JWT
  static String? jwt_token;

  static Future<String?> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      body: {'username': username, 'password': password},
    );
    if (response.statusCode == 200) {
      jwt_token = jsonDecode(response.body)['access_token']; // Guarda el token en la variable global
      await JwtStorage.saveToken(jwt_token!); // Guarda el token en el almacenamiento local
      return jwt_token;
    }
    return null;
  }

  static Future<String?> register(String name, String username, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      body: {
        'name': name,
        'username': username,
        'email': email,
        'password': password,
      },
    );
    if (response.statusCode == 200) {
      jwt_token = jsonDecode(response.body)['token']; // Guarda el token en la variable global
      await JwtStorage.saveToken(jwt_token!); // Guarda el token en el almacenamiento local
      return jwt_token;
    }
    return null;
  }

  static Future<http.Response?> logout(String token) async {
    final url = Uri.parse('$baseUrl/auth/logout');

    try{
      // Enviar el token en la cabecera Authorization
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token', // Enviar el token como Bearer Token
        },
      );

      return response;
    } on SocketException{
      throw ("Upss..\nSin conexión a internet :((");
    }
  }
}
