import 'dart:convert';
import 'package:http/http.dart' as http;
import 'jwt_storage.dart'; // Asegúrate de que este archivo contenga la lógica de almacenamiento de tokens.
import 'server.dart';

Future<List<Map<String, dynamic>>> fetchConnections() async {
  final url = Uri.parse('${Server.baseUrl}/list-connections');

  // Obtén el token desde SharedPreferences
  final jwtToken = await JwtStorage.getToken();

  if (jwtToken == null) {
    throw Exception('JWT Token is missing. Please log in again.');
  }

  final headers = {
    'Authorization': 'Bearer $jwtToken', // Incluye el token obtenido
    'Content-Type': 'application/json',
  };

  final response = await http.get(url, headers: headers);

  print("RESPONSE STATUS CODE: ${response.statusCode}");

  if (response.statusCode == 200) {
    // Decodifica la respuesta JSON en una lista de mapas
    return List<Map<String, dynamic>>.from(json.decode(response.body));
  } else {
    throw Exception('Failed to load connections');
  }
}
