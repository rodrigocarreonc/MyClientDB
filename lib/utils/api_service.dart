import 'dart:convert';
import 'package:http/http.dart' as http;
import 'jwt_storage.dart';
import 'server.dart';

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  // Obtener la lista de bases de datos
  Future<List<Map<String, dynamic>>> fetchDatabases(int connectionId) async {
    final url = Uri.parse('$baseUrl/databases/$connectionId');

    // Obtener el JWT desde SharedPreferences
    final jwtToken = await JwtStorage.getToken();

    if (jwtToken == null) {
      throw Exception('JWT Token is missing. Please log in again.');
    }

    final headers = {
      'Authorization': 'Bearer $jwtToken',
      'Content-Type': 'application/json',
    };

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception(
        'Failed to load databases. Status code: ${response.statusCode}',
      );
    }
  }

  // Obtener la lista de tablas en una base de datos
  Future<List<Map<String, dynamic>>> fetchTables(int connectionId, String database) async {
    final url = Uri.parse('$baseUrl/list-tables/$connectionId');

    // Obtener el JWT desde SharedPreferences
    final jwtToken = await JwtStorage.getToken();

    if (jwtToken == null) {
      throw Exception('JWT Token is missing. Please log in again.');
    }

    final headers = {
      'Authorization': 'Bearer $jwtToken',
      'Content-Type': 'application/json',
    };

    final body = json.encode({'database': database});

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception(
        'Failed to load tables. Status code: ${response.statusCode}',
      );
    }
  }

  // Ejecutar una consulta en una base de datos
  Future<List<Map<String, dynamic>>> executeQuery(
      int connectionId,
      String database,
      String query,
      ) async {
    final url = Uri.parse('$baseUrl/execute-query/$connectionId');

    // Obtener el JWT desde SharedPreferences
    final jwtToken = await JwtStorage.getToken();

    if (jwtToken == null) {
      throw Exception('JWT Token is missing. Please log in again.');
    }

    final headers = {
      'Authorization': 'Bearer $jwtToken',
      'Content-Type': 'application/json',
    };

    final body = json.encode({'database': database, 'query': query});

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception(
        'Failed to execute query. Status code: ${response.statusCode}',
      );
    }
  }
}
