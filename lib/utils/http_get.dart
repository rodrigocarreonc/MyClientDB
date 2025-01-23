import 'dart:convert';
import 'package:http/http.dart' as http;
import 'jwt_storage.dart'; // Asegúrate de que este archivo contenga la lógica de almacenamiento de tokens.
import 'server.dart';
import 'dart:io';

Future<List<Map<String, dynamic>>> fetchConnections() async {
  final url = Uri.parse('${Server.baseUrl}/list-connections');

  try{
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

    if (response.statusCode == 200) {
      // Decodifica la respuesta JSON en una lista de mapas
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to load connections');
    }

  } on SocketException{
    throw ("Upss..\nSin conexión a internet :((");
  }catch(e){
    throw Exception('Error inesperado: $e');
  }

}
