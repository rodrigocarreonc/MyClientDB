import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'jwt_storage.dart';

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  Future<List<Map<String, dynamic>>> getConnections() async {
    final url = Uri.parse('$baseUrl/list-connections');

    try {
      final jwtToken = await JwtStorage.getToken();

      final headers = {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      };

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      else {
        throw Exception('Error al obtener las conexiones: ${response.body}');
      }
    } on SocketException{
      throw ('Upss..\nSin conexión a internet :((');
    }
    catch (e) {
      throw Exception('Error de red: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> testConnection({
    required String host,
    required int port, // Cambiado a int
    required String username,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/test-connection');
    try{
      final jwtToken = await JwtStorage.getToken();

      final headers = {
        'Authorization':'Bearer $jwtToken',
        'Content-Type':'application/json',
      };

      final body = json.encode({
        'host':host,
        'port':port,
        'username':username,
        'password':password,
      });

      final response = await http.post(url,headers: headers,body: body);

      if (response.statusCode == 200 || response.statusCode == 404){
        return jsonDecode(response.body);
      }else{
        throw ('Ocurrio un error: ${response.body}');
      }
    }on SocketException {
      throw ('Upss..\nSin conexión a internet :((');
    } catch (e) {
      throw ('Error de red: ${e.toString()}');
    }
}

  Future<Map<String, dynamic>> addConnection({
    required String host,
    required int port, // Cambiado a int
    required String username,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/add-connection');

    try {
      final jwtToken = await JwtStorage.getToken();

      final headers = {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      };

      final body = json.encode({
        'host': host,
        'port': port, // Enviado como int
        'username': username,
        'password': password,
      });

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al agregar la conexión: ${response.body}');
      }
    } on SocketException {
      throw ('Upss..\nSin conexión a internet :((');
    } catch (e) {
      throw Exception('Error de red: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> editConnection({
    required int connectionId,
    required String host,
    required int port,
    required String username,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/edit-connection/$connectionId');

    try {
      final jwtToken = await JwtStorage.getToken();

      final headers = {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      };

      final body = json.encode({
        'host': host,
        'port': port,
        'username': username,
        'password': password,
      });

      final response = await http.put(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al editar la conexión: ${response.body}');
      }
    } on SocketException {
      throw ('Upss..\nSin conexión a internet :((');
    } catch (e) {
      throw Exception('Error de red: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> deleteConnection(int connectionId) async {
    final url = Uri.parse('$baseUrl/delete-connection/$connectionId');

    try {
      final jwtToken = await JwtStorage.getToken();

      final headers = {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      };

      final response = await http.delete(url, headers: headers);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al eliminar la conexión: ${response.body}');
      }
    } on SocketException {
      throw ('Upss..\nSin conexión a internet :((');
    } catch (e) {
      throw Exception('Error de red: ${e.toString()}');
    }
  }

  // Obtener la lista de bases de datos
  Future<List<Map<String, dynamic>>> fetchDatabases(int connectionId) async {
    final url = Uri.parse('$baseUrl/databases/$connectionId');

    try{
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
    } on SocketException{
      throw ("Upss..\nSin conexión a internet :((");
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

    try{

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
      }
      else {
        throw (
            json.decode(response.body)['message']
        );
      }
    } on SocketException{
      throw (
          "Upss..\nSin conexión a internet :(("
      );
    }
  }
}
